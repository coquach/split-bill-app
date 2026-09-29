//
//  TransferDetail.swift
//  Domains
//

import Foundation

public struct TransferDetail: Identifiable, Sendable, Equatable {
    public let id: UUID
    public let transactionRef: String
    public let senderUserId: UUID
    public let recipientUserId: UUID
    public let amount: Int64
    public let fee: Int64
    public let description: String?
    public let status: TransferStatus
    public let completedAt: Date?
    public let createdAt: Date
    public let currency: String
    public let splitBillId: UUID?
    public let canCreateSplitBill: Bool
    public let isSplitBillRepayment: Bool

    public init(
        id: UUID,
        transactionRef: String,
        senderUserId: UUID,
        recipientUserId: UUID,
        amount: Int64,
        fee: Int64,
        description: String?,
        status: TransferStatus,
        completedAt: Date?,
        createdAt: Date,
        currency: String,
        splitBillId: UUID?,
        canCreateSplitBill: Bool,
        isSplitBillRepayment: Bool
    ) {
        self.id = id
        self.transactionRef = transactionRef
        self.senderUserId = senderUserId
        self.recipientUserId = recipientUserId
        self.amount = amount
        self.fee = fee
        self.description = description
        self.status = status
        self.completedAt = completedAt
        self.createdAt = createdAt
        self.currency = currency
        self.splitBillId = splitBillId
        self.canCreateSplitBill = canCreateSplitBill
        self.isSplitBillRepayment = isSplitBillRepayment
    }
}
