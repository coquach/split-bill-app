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

    // MARK: - Form fields

    public var accountNumber: String = "" {
        didSet { scheduleAccountLookup() }
    }
    public var amountText: String = ""
    public var descriptionText: String = ""

    // MARK: - Lookup state

    public private(set) var lookupState: AccountLookupState = .idle

    // MARK: - Dependencies

    private let accountRepository: IAccountRepository
    private let sessionStore: SessionStore

    private var lookupTask: Task<Void, Never>?

    public init(accountRepository: IAccountRepository, sessionStore: SessionStore) {
        self.accountRepository = accountRepository
        self.sessionStore = sessionStore
    }

    // MARK: - Derived state

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

    // MARK: - Actions

    public func selectQuickAmount(_ value: Int) {
        amountText = String(value)
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

    // MARK: - Account lookup

    // Debounces the lookup so we don't fire a request on every keystroke:
    // cancel whatever's in flight, wait a beat, then only proceed if
    // nothing newer has come in since.
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
                // Superseded by a newer keystroke - nothing to show.
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
