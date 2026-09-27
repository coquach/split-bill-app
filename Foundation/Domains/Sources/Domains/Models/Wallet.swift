//
//  Wallet.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Foundation

public struct Wallet: Identifiable, Sendable, Equatable {
    public let id: UUID
    public let userId: UUID
    public let walletNumber: String
    public let walletHolderName: String
    public let isDefault: Bool
    public let status: WalletStatus
    public let balance: Int64
    public let currency: String
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: UUID,
        userId: UUID,
        walletNumber: String,
        walletHolderName: String,
        isDefault: Bool,
        status: WalletStatus,
        balance: Int64,
        currency: String,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.userId = userId
        self.walletNumber = walletNumber
        self.walletHolderName = walletHolderName
        self.isDefault = isDefault
        self.status = status
        self.balance = balance
        self.currency = currency
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
