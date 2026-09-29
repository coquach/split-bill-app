//
//  Repayment.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Foundation

public struct Repayment: Identifiable, Sendable, Equatable {
    public let id: UUID
    public let splitBillId: UUID
    public let payerUserId: UUID?
    public let transferTransactionId: UUID?
    public let paymentMethod: PaymentMethod
    public let amount: Amount
    public let currency: String
    public let payerDisplayName: String
    public let note: String?
    public let status: RepaymentStatus
    public let idempotencyKey: String
    public let paidAt: Date?
    public let createdAt: Date

    public init(
        id: UUID,
        splitBillId: UUID,
        payerUserId: UUID?,
        transferTransactionId: UUID?,
        paymentMethod: PaymentMethod,
        amount: Amount,
        currency: String,
        payerDisplayName: String,
        note: String?,
        status: RepaymentStatus,
        idempotencyKey: String,
        paidAt: Date?,
        createdAt: Date
    ) {
        self.id = id
        self.splitBillId = splitBillId
        self.payerUserId = payerUserId
        self.transferTransactionId = transferTransactionId
        self.paymentMethod = paymentMethod
        self.amount = amount
        self.currency = currency
        self.payerDisplayName = payerDisplayName
        self.note = note
        self.status = status
        self.idempotencyKey = idempotencyKey
        self.paidAt = paidAt
        self.createdAt = createdAt
    }
}

public struct RepaymentRecord: Sendable, Equatable {
    public let repayment: Repayment
    public let splitBill: SplitBill?

    public init(repayment: Repayment, splitBill: SplitBill?) {
        self.repayment = repayment
        self.splitBill = splitBill
    }
}
