//
//  TransferTransaction.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Foundation

public struct TransferTransaction: Identifiable, Sendable, Equatable {
    public let id: UUID
    public let senderUserId: UUID
    public let senderWalletId: UUID
    public let recipientUserId: UUID
    public let recipientWalletId: UUID
    public let amount: Int64
    public let fee: Int64
    public let currency: String
    public let description: String?
    public let status: TransferStatus
    public let transactionRef: String
    public let idempotencyKey: String
    public let completedAt: Date?
    public let createdAt: Date

    public init(
        id: UUID,
        senderUserId: UUID,
        senderWalletId: UUID,
        recipientUserId: UUID,
        recipientWalletId: UUID,
        amount: Int64,
        fee: Int64,
        currency: String,
        description: String?,
        status: TransferStatus,
        transactionRef: String,
        idempotencyKey: String,
        completedAt: Date?,
        createdAt: Date
    ) {
        self.id = id
        self.senderUserId = senderUserId
        self.senderWalletId = senderWalletId
        self.recipientUserId = recipientUserId
        self.recipientWalletId = recipientWalletId
        self.amount = amount
        self.fee = fee
        self.currency = currency
        self.description = description
        self.status = status
        self.transactionRef = transactionRef
        self.idempotencyKey = idempotencyKey
        self.completedAt = completedAt
        self.createdAt = createdAt
    }
}
