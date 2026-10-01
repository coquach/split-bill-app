//
//  MockWalletRepository.swift
//  TransferTests
//

import Domains
import Foundation

final class MockWalletRepository: IWalletRepository, @unchecked Sendable {
    var recipient: WalletRecipient?
    var error: Error?

    private(set) var resolveWalletCalls = 0
    private(set) var lastResolvedQuery: String?

    func getDefaultWallet() async throws -> Wallet {
        throw DomainError.notFound
    }

    func getWallets() async throws -> [Wallet] { [] }

    func resolveWallet(walletNumber: String) async throws -> WalletRecipient {
        resolveWalletCalls += 1
        lastResolvedQuery = walletNumber
        if let error { throw error }
        guard let recipient else {
            throw DomainError.notFound
        }
        return recipient
    }
}
