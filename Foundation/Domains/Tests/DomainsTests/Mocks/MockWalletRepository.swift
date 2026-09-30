//
//  MockWalletRepository.swift
//  DomainsTests
//

import Domains
import Foundation

final class MockWalletRepository: IWalletRepository, @unchecked Sendable {
    var wallet: Wallet?
    var wallets: [Wallet] = []
    var recipient: WalletRecipient?
    var error: Error?

    private(set) var getDefaultWalletCalls = 0
    private(set) var getWalletsCalls = 0
    private(set) var resolveWalletCalls = 0

    func getDefaultWallet() async throws -> Wallet {
        getDefaultWalletCalls += 1
        if let error { throw error }
        guard let wallet else {
            throw DomainError.notFound
        }
        return wallet
    }

    func getWallets() async throws -> [Wallet] {
        getWalletsCalls += 1
        if let error { throw error }
        return wallets
    }

    func resolveWallet(walletNumber: String) async throws -> WalletRecipient {
        resolveWalletCalls += 1
        if let error { throw error }
        guard let recipient else {
            throw DomainError.notFound
        }
        return recipient
    }
}
