//
//  IWalletRepository.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Foundation

public protocol IWalletRepository: Sendable {
    func getDefaultWallet() async throws -> Wallet
    func getWallets() async throws -> [Wallet]
    func resolveWallet(walletNumber: String) async throws -> WalletRecipient
}

public struct WalletRecipient: Sendable, Equatable {
    public let walletNumber: String
    public let holderName: String

    public init(walletNumber: String, holderName: String) {
        self.walletNumber = walletNumber
        self.holderName = holderName
    }
}
