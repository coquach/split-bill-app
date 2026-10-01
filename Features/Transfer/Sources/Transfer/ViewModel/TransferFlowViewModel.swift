//
//  TransferFlowViewModel.swift
//  Transfer
//
//  Created by Dinh Long on 30/9/26.
//

import Combine
import Domains
import Foundation
import Observation

// One ViewModel for the whole Input -> Confirm -> OTP -> Success flow.
// The draft and the submission result live here once, so nothing needs to
// re-pass them through each screen's initializer.
@MainActor
@Observable
public final class TransferFlowViewModel {

    public enum SubmissionState: Equatable {
        case idle
        case verifying
        case failed(DomainError)
    }

    // MARK: - Input step

    /// How long to wait after the last keystroke before looking the account
    /// number up. Single source of truth for the debounce: the public
    /// Duration (tests wait on it) and the Dispatch stride Combine's
    /// `.debounce` uses both derive from it — there is no public
    /// Duration → Stride conversion to go the other way.
    private static let accountLookupDebounceMs = 400

    public static let accountLookupDebounce: Duration = .milliseconds(accountLookupDebounceMs)

    private static let accountLookupDebounceStride: DispatchQueue.SchedulerTimeType.Stride = .milliseconds(accountLookupDebounceMs)

    public var accountNumber: String = "" {
        didSet { scheduleAccountLookup() }
    }
    public var amountText: String = ""
    public var descriptionText: String = ""

    public private(set) var lookupState: AccountLookupState = .idle

    public private(set) var draft: TransferDraft?
    public var pin: String = ""
    public private(set) var state: SubmissionState = .idle
    public private(set) var receipt: TransferReceipt?

    private let walletRepository: IWalletRepository
    private let sessionStore: SessionStore
    private let transferRepository: ITransferRepository

    private var lookupTask: Task<Void, Never>?
    private var idempotencyKey = UUID().uuidString

    private let accountNumberSubject = PassthroughSubject<String, Never>()
    private var isLookupCancelled = false
    private var cancellables = Set<AnyCancellable>()

    public init(
        walletRepository: IWalletRepository,
        sessionStore: SessionStore,
        transferRepository: ITransferRepository
    ) {
        self.walletRepository = walletRepository
        self.sessionStore = sessionStore
        self.transferRepository = transferRepository

        accountNumberSubject
            .debounce(for: Self.accountLookupDebounceStride, scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                Task { @MainActor in
                    self?.performLookup(query)
                }
            }
            .store(in: &cancellables)
    }

    public var amount: Amount {
        Amount(Double(amountText) ?? 0)
    }

    public var availableBalance: Amount? {
        sessionStore.availableBalance
    }

    public var exceedsAvailableBalance: Bool {
        guard let balance = sessionStore.availableBalance else {
            return false
        }
        return amount.amount > 0 && amount > balance
    }

    public var isFormValid: Bool {
        guard case .found = lookupState else { return false }
        guard amount.amount > 0 else { return false }
        guard !exceedsAvailableBalance else { return false }
        return true
    }

    public func selectQuickAmount(_ value: Int) {
        amountText = String(value)
    }

    // Called on view disappear so a stale lookup doesn't resolve after
    // the user has already navigated away.
    public func cancelPendingLookup() {
        isLookupCancelled = true
        lookupTask?.cancel()
    }

    // Builds the draft from the current input and stores it on the VM, so
    // Confirm and OTP read it from here instead of receiving their own copy.
    @discardableResult
    public func confirmInput() -> Bool {
        guard case .found(let recipient) = lookupState else { return false }

        draft = TransferDraft(
            // The wallet id from the lookup, not the number the user typed —
            // it's what `create_transfer` actually takes.
            receiverWalletId: recipient.walletId,
            receiverAccountNumber: recipient.walletNumber,
            receiverHolderName: recipient.holderName,
            amount: amount,
            description: descriptionText.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
        )
        return true
    }

    private func scheduleAccountLookup() {
        isLookupCancelled = false
        lookupTask?.cancel()
        let query = accountNumber
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
        guard !query.isEmpty else {
            lookupState = .idle
            return
        }

        lookupState = .loading
        accountNumberSubject.send(query)
    }

    // Runs once the Combine debounce settles on a query.
    private func performLookup(_ query: String) {
        guard !isLookupCancelled else { return }

        lookupTask = Task { [walletRepository] in
            do {
                let recipient = try await walletRepository.resolveWallet(walletNumber: query)
                guard !Task.isCancelled else { return }
                lookupState = .found(recipient)
            } catch is CancellationError {
            } catch DomainError.notFound {
                guard !Task.isCancelled else { return }
                lookupState = .notFound
            } catch {
                guard !Task.isCancelled else { return }
                lookupState = .failed("Couldn't look up this account. Check your connection and try again.")
            }
        }
    }

    // MARK: - Confirm step

    public var maskedAccountNumber: String {
        guard let draft else { return "" }
        return "•••• \(draft.receiverAccountNumber.suffix(4))"
    }

    // MARK: - OTP step

    public var isPinComplete: Bool {
        pin.count == TransferPIN.length
    }

    public var errorMessage: String? {
        guard case .failed(let error) = state else { return nil }
        return error.message
    }

    public func submitOTP() async {
        guard let draft, isPinComplete, state != .verifying else { return }

        state = .verifying

        let command = CreateTransferCommand(
            recipientWalletId: draft.receiverWalletId,
            amount: Int64(draft.amount.amount.rounded()),
            description: draft.description.isEmpty ? nil : draft.description,
            pin: pin,
            idempotencyKey: idempotencyKey
        )

        do {
            let transaction = try await transferRepository.createTransfer(command)
            receipt = TransferReceipt(transaction: transaction, draft: draft)
            state = .idle
            // Tell Home and History to reload now, instead of waiting for the next time they appear
            NotificationCenter.default.post(name: .transactionsDidChange, object: nil)
        } catch let error as DomainError {
            handleFailure(error)
        } catch {
            handleFailure(.unknown(code: nil, message: error.localizedDescription))
        }
    }

    private func handleFailure(_ error: DomainError) {
        switch error {
        case .invalidPin, .invalidPinFormat, .pinLocked, .validation,
             .insufficientBalance:
            idempotencyKey = UUID().uuidString
        default:
            break
        }

        state = .failed(error)
    }

    public func retry() {
        pin = ""
        state = .idle
    }
}
