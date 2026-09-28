//
//  TransferResult.swift
//  Domains
//
//  Created by Dinh Long on 28/9/26.
//

import Foundation

/// Exactly what the `create_transfer` RPC returns — eight columns, no more.
///
/// It has no receiver name or account number on purpose: the RPC doesn't
/// return them, and quietly filling them in here would hide that fact from
/// every reader after us. `TransferReceipt` is where this server result and
/// the draft the user confirmed get combined for display.
public struct TransferResult: Sendable, Equatable, Hashable {
    public let id: UUID
    public let transactionRef: String
    public let status: TransferStatus
    public let amount: Amount
    public let fee: Amount
    public let description: String?
    public let completedAt: Date?
    public let createdAt: Date

    public init(
        id: UUID,
        transactionRef: String,
        status: TransferStatus,
        amount: Amount,
        fee: Amount,
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
