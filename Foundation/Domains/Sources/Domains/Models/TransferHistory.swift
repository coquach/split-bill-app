//
//  TransferHistory.swift
//  Domains
//

import Foundation

public struct TransferHistory: Identifiable, Sendable, Equatable {
    public let id: UUID
    public let transactionRef: String
    public let direction: TransferDirection
    public let senderUserId: UUID
    public let senderWalletId: UUID
    public let recipientUserId: UUID
    public let recipientWalletId: UUID
    public let amount: Int64
    public let fee: Int64
    public let description: String?
    public let status: TransferStatus
    public let currency: String
    public let counterpartyWalletNumber: String?
    public let counterpartyName: String?
    public let completedAt: Date?
    public let createdAt: Date
    public let isRepayment: Bool
    public let repaymentId: UUID?
    public let totalCount: Int64

    public init(
        id: UUID,
        transactionRef: String,
        direction: TransferDirection,
        senderUserId: UUID,
        senderWalletId: UUID,
        recipientUserId: UUID,
        recipientWalletId: UUID,
        amount: Int64,
        fee: Int64,
        description: String?,
        status: TransferStatus,
        currency: String,
        counterpartyWalletNumber: String?,
        counterpartyName: String?,
        completedAt: Date?,
        createdAt: Date,
        isRepayment: Bool,
        repaymentId: UUID?,
        totalCount: Int64
    ) {
        self.id = id
        self.transactionRef = transactionRef
        self.direction = direction
        self.senderUserId = senderUserId
        self.senderWalletId = senderWalletId
        self.recipientUserId = recipientUserId
        self.recipientWalletId = recipientWalletId
        self.amount = amount
        self.fee = fee
        self.description = description
        self.status = status
        self.currency = currency
        self.counterpartyWalletNumber = counterpartyWalletNumber
        self.counterpartyName = counterpartyName
        self.completedAt = completedAt
        self.createdAt = createdAt
        self.isRepayment = isRepayment
        self.repaymentId = repaymentId
        self.totalCount = totalCount
    }
}

public enum TransferDirection: String, Codable, Sendable, Equatable {
    case sent = "SENT"
    case received = "RECEIVED"
}
