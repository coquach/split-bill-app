//
//  TransferTransaction.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Foundation

// Exactly the 8 columns `create_transfer` returns. It does not return the
// sender/recipient ids, currency or idempotency key.
public struct TransferTransaction: Identifiable, Sendable, Equatable {
    public let id: UUID
    public let transactionRef: String
    public let status: TransferStatus
    public let amount: Int64
    public let fee: Int64
    public let description: String?
    public let completedAt: Date?
    public let createdAt: Date

    public init(
        id: UUID,
        transactionRef: String,
        status: TransferStatus,
        amount: Int64,
        fee: Int64,
        description: String?,
        completedAt: Date?,
        createdAt: Date
    ) {
        self.id = id
        self.transactionRef = transactionRef
        self.status = status
        self.amount = amount
        self.fee = fee
        self.description = description
        self.completedAt = completedAt
        self.createdAt = createdAt
    }
}
