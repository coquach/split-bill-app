//
//  TransferDetail.swift
//  Domains
//
//  Created by Dinh Long on 28/9/26.
//

import Foundation

/// One row of the `get_transfer_detail` RPC.
///
/// Note what isn't here: the counterparty's name. `get_transfer_detail`
/// doesn't return it, so the Detail screen takes the name from whoever
/// opened it (the Success screen has it on the receipt). Once transaction
/// history exists it can come from `get_transfer_history`, which does
/// return `counterparty_name`.
public struct TransferDetail: Identifiable, Sendable, Equatable, Hashable {
    public let id: UUID
    public let transactionRef: String
    public let senderUserId: UUID
    public let recipientUserId: UUID
    public let amount: Amount
    public let fee: Amount
    public let description: String?
    public let status: TransferStatus
    public let completedAt: Date?
    public let createdAt: Date

    // MARK: - Split-bill context

    /// Set once this transfer has been split. Nil means it hasn't been.
    public let splitBillId: UUID?

    /// The backend's answer to "may this transfer be split?" — it accounts
    /// for things the client can't see (ownership, age, status, whether a
    /// split already exists). Drive the Split Bill button off this, never
    /// off a locally re-derived rule.
    public let canCreateSplitBill: Bool

    /// True when this transfer *is* someone repaying a split, rather than a
    /// plain transfer that could become one.
    public let isSplitBillRepayment: Bool

    public init(
        id: UUID,
        transactionRef: String,
        senderUserId: UUID,
        recipientUserId: UUID,
        amount: Amount,
        fee: Amount,
        description: String?,
        status: TransferStatus,
        completedAt: Date?,
        createdAt: Date,
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
        self.splitBillId = splitBillId
        self.canCreateSplitBill = canCreateSplitBill
        self.isSplitBillRepayment = isSplitBillRepayment
    }
}
