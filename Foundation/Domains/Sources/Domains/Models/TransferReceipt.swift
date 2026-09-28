//
//  TransferReceipt.swift
//  Domains
//
//  Created by Dinh Long on 26/9/26.
//

import Foundation

/// What the Success screen shows, and what it hands to Transaction Detail.
///
/// It's a merge of two sources, because neither one is enough on its own:
/// the transaction fields come from `TransferResult` (the `create_transfer`
/// RPC), while the receiver's name and account number come from the
/// `TransferDraft` the user just confirmed — the RPC doesn't return either.
public struct TransferReceipt: Sendable, Equatable, Hashable {

    // MARK: - From the server

    public let id: UUID
    public let transactionRef: String
    public let status: TransferStatus
    public let amount: Amount
    public let fee: Amount
    public let description: String
    public let completedAt: Date?
    public let createdAt: Date

    // MARK: - Carried from the draft

    public let receiverAccountNumber: String
    public let receiverHolderName: String

    public init(result: TransferResult, draft: TransferDraft) {
        self.id = result.id
        self.transactionRef = result.transactionRef
        self.status = result.status
        self.amount = result.amount
        self.fee = result.fee
        // Prefer whatever the server echoed back, since that's the row of
        // record. Fall back to the draft so the receipt still reads
        // correctly if the RPC normalises an empty description to null.
        self.description = result.description ?? draft.description
        self.completedAt = result.completedAt
        self.createdAt = result.createdAt
        self.receiverAccountNumber = draft.receiverAccountNumber
        self.receiverHolderName = draft.receiverHolderName
    }
}
