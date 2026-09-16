//
//  TransferFlowViewModel.swift
//  SplitPay
//
//  Created by Dinh Long on 17/9/26.
//

import Foundation
import Combine

struct TransferDraft {
    var receiverAccountNumber: String = ""
    var amount: Amount = .zero
    var description: String = ""
}

@MainActor
final class TransferFlowViewModel: ObservableObject {

    @Published var draft = TransferDraft()

    @Published private(set) var accountLookupState: AccountLookupState = .idle

    private let dependency: TransferDependency
    private var cancellables = Set<AnyCancellable>()

    init(dependency: TransferDependency) {
        self.dependency = dependency
        observeAccountNumberChanges()
    }

    var availableBalance: Amount {
        dependency.sessionStore.availableBalance
    }

    var isFormValid: Bool {
        guard case .found = accountLookupState else { return false }
        guard Amount.zero.isLessThan(draft.amount) else { return false }
        guard !availableBalance.isLessThan(draft.amount) else { return false }
        return true
    }

    func selectQuickAmount(_ amount: Amount) {
        draft.amount = amount
    }

    private func observeAccountNumberChanges() {
        $draft
            .map(\.receiverAccountNumber)
            .removeDuplicates()
            .debounce(for: .milliseconds(400), scheduler: DispatchQueue.main)
            .sink { [weak self] accountNumber in
                Task { await self?.lookupAccount(accountNumber) }
            }
            .store(in: &cancellables)
    }

    private func lookupAccount(_ accountNumber: String) async {
        guard !accountNumber.isEmpty else {
            accountLookupState = .idle
            return
        }

        accountLookupState = .loading
        do {
            if let account = try await dependency.accountResolver.resolveAccount(accountNumber: accountNumber) {
                accountLookupState = .found(account)
            } else {
                accountLookupState = .notFound
            }
        } catch {
            accountLookupState = .notFound
        }
    }
}
