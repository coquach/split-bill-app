//
//  QRRepaymentReceipt.swift
//  Domains
//
//  Created by Dinh Long on 29/9/26.
//

import Foundation

// create_qr_repayment's actual columns - distinct from Repayment (a full repayments row); this RPC doesn't return payer/currency/note/created_at.
public struct QRRepaymentReceipt: Sendable, Equatable, Hashable {
    public let id: UUID
    public let splitBillId: UUID
    public let transferTransactionId: UUID
    public let amount: Amount
    public let paymentMethod: PaymentMethod
    public let status: RepaymentStatus
    public let paidSlots: Int
    public let splitBillStatus: SplitBillStatus
    public let paidAt: Date?

    public init(
        id: UUID,
        splitBillId: UUID,
        transferTransactionId: UUID,
        amount: Amount,
        paymentMethod: PaymentMethod,
        status: RepaymentStatus,
        paidSlots: Int,
        splitBillStatus: SplitBillStatus,
        paidAt: Date?
    ) {
        self.id = id
        self.splitBillId = splitBillId
        self.transferTransactionId = transferTransactionId
        self.amount = amount
        self.paymentMethod = paymentMethod
        self.status = status
        self.paidSlots = paidSlots
        self.splitBillStatus = splitBillStatus
        self.paidAt = paidAt
    }
}
