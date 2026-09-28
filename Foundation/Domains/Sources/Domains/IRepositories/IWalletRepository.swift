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

/// One row of the `resolve_wallet_by_number` RPC.
///
/// `walletId` matters more than it looks: it's what `create_transfer` wants
/// as `p_recipient_wallet_id`. The wallet number the user types is only ever
/// a lookup key — it never goes to the backend as an identifier.
public struct WalletRecipient: Sendable, Equatable, Hashable {
    public let walletId: UUID
    public let walletNumber: String
    public let holderName: String

    public init(
        walletId: UUID,
        walletNumber: String,
        holderName: String
    ) {
        self.walletId = walletId
        self.walletNumber = walletNumber
        self.holderName = holderName
    }
}
