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

    private let accountRepository: IAccountRepository
    private let sessionStore: SessionStore

    private var lookupTask: Task<Void, Never>?

    public init(accountRepository: IAccountRepository, sessionStore: SessionStore) {
        self.accountRepository = accountRepository
        self.sessionStore = sessionStore
    }

    public var amount: Amount {
        Amount(Double(amountText) ?? 0)
    }

    public var availableBalance: Amount {
        sessionStore.availableBalance
    }

    public var exceedsAvailableBalance: Bool {
        amount.amount > 0 && amount > sessionStore.availableBalance
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
        guard case .found(let account) = lookupState else { return nil }
        return TransferDraft(
            receiverAccountNumber: account.accountNumber,
            receiverHolderName: account.holderName,
            amount: amount,
            description: descriptionText
        )
    }

    private func scheduleAccountLookup() {
        lookupTask?.cancel()

        let query = accountNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            lookupState = .idle
            return
        }

        lookupState = .loading

        lookupTask = Task { [accountRepository] in
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }

            do {
                let account = try await accountRepository.resolveAccount(accountNumber: query)
                guard !Task.isCancelled else { return }
                lookupState = .found(account)
            } catch is CancellationError {
            } catch AccountRepositoryError.notFound {
                guard !Task.isCancelled else { return }
                lookupState = .notFound
            } catch {
                guard !Task.isCancelled else { return }
                lookupState = .failed("Couldn't look up this account. Check your connection and try again.")
            }
        }
    }
}
