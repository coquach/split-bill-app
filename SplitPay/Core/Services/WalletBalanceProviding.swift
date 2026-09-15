//
//  WalletBalanceProviding.swift
//  SplitPay
//
//  Created by Dinh Long on 14/9/26.
//

import Foundation

protocol WalletBalanceProviding {
    func fetchAvailableBalance() async throws -> Amount
}

final class MockWalletBalanceProvidingService: WalletBalanceProviding {
    func fetchAvailableBalance() async throws -> Amount {
        try await Task.sleep(nanoseconds: 500_000_000)
        return Amount(amount: 14_820_000)
    }
}
