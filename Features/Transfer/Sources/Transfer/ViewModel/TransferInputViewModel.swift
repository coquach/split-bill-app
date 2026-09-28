//
//  TransferInputViewModel.swift
//  Transfer
//
//  Created by Dinh Long on 26/9/26.
//

import Domains
import Foundation
import Observation

@MainActor
@Observable
public final class TransferInputViewModel {

    public var accountNumber: String = "" {
        didSet { scheduleAccountLookup() }
    }
    public var amountText: String = ""
    public var descriptionText: String = ""

    public private(set) var lookupState: AccountLookupState = .idle

    private let walletRepository: IWalletRepository
    private let sessionStore: SessionStore

    private var lookupTask: Task<Void, Never>?

    public init(walletRepository: IWalletRepository, sessionStore: SessionStore) {
        self.walletRepository = walletRepository
        self.sessionStore = sessionStore
    }

    public var amount: Amount {
        Amount(Double(amountText) ?? 0)
    }

    /// `nil` while the balance hasn't loaded — the view shows that state
    /// rather than pretending the wallet is empty.
    public var availableBalance: Amount? {
        sessionStore.availableBalance
    }

    /// Only ever true when we actually know the balance. If the fetch hasn't
    /// landed we let the transfer through and let `create_transfer` reject
    /// it: the server re-checks the real balance regardless, and blocking on
    /// a number we failed to load would strand the user with no way forward.
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
        lookupTask?.cancel()
    }

    public func makeDraft() -> TransferDraft? {
        guard case .found(let recipient) = lookupState else { return nil }
        return TransferDraft(
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
    }

    private func scheduleAccountLookup() {
        lookupTask?.cancel()

        // Normalise before it leaves the app: wallet numbers are stored
        // uppercase, and the lookup may well be a plain equality check.
        // Trim first so a trailing space from paste or autocomplete doesn't
        // turn into a "not found".
        let query = accountNumber
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
        guard !query.isEmpty else {
            lookupState = .idle
            return
        }

        lookupState = .loading

        lookupTask = Task { [walletRepository] in
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }

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
}
