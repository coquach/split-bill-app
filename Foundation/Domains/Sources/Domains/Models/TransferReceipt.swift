//
//  TransferReceipt.swift
//  Domains
//
//  Created by Dinh Long on 26/9/26.
//

import Foundation

/// What the Success screen shows, and what it hands to Transaction Detail.
///
// Server fields plus the receiver from the draft; the backend returns no name.
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

    public init(transaction: TransferTransaction, draft: TransferDraft) {
        self.id = transaction.id
        self.transactionRef = transaction.transactionRef
        self.status = transaction.status
        self.amount = Amount(Double(transaction.amount))
        self.fee = Amount(Double(transaction.fee))
        // Prefer whatever the server echoed back, since that's the row of
        // record. Fall back to the draft so the receipt still reads
        // correctly if the RPC normalises an empty description to null.
        self.description = transaction.description ?? draft.description
        self.completedAt = transaction.completedAt
        self.createdAt = transaction.createdAt
        self.receiverAccountNumber = draft.receiverAccountNumber
        self.receiverHolderName = draft.receiverHolderName
    }
}
