//
//  AccountResolving.swift
//  SplitPay
//
//  Created by Dinh Long on 14/9/26.
//

import Foundation

enum AccountLookupState: Equatable {
    case idle
    case loading
    case found(ResolvedAccount)
    case notFound
}

protocol AccountResolving {
    func resolveAccount(accountNumber: String) async throws -> ResolvedAccount?
}

final class MockAccountResolvingService: AccountResolving {

    private let knownAccounts: [String: String] = [
        "1029384756": "Nguyen Van An",
        "1122334455": "Tran Thi Bich",
        "9988776655": "Le Hoang Nam"
    ]

    func resolveAccount(accountNumber: String) async throws -> ResolvedAccount? {
        try await Task.sleep(nanoseconds: 500_000_000)

        guard let holderName = knownAccounts[accountNumber] else {
            return nil
        }
        return ResolvedAccount(accountNumber: accountNumber, holderName: holderName)
    }
}
