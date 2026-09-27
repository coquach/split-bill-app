//
//  TransferReceipt.swift
//  Domains
//
//  Created by Dinh Long on 26/9/26.
//

import Foundation

/// What the backend hands back once a transfer actually goes through —
/// the 201 Created body of `POST /transfers`.
public struct TransferReceipt: Sendable, Equatable, Hashable {
    public let id: String
    public let receiverAccountNumber: String
    public let receiverHolderName: String
    public let amount: Amount
    public let description: String
    public let createdAt: Date
    public let status: String

    public init(
        id: String,
        receiverAccountNumber: String,
        receiverHolderName: String,
        amount: Amount,
        description: String,
        createdAt: Date,
        status: String
    ) {
        self.id = id
        self.receiverAccountNumber = receiverAccountNumber
        self.receiverHolderName = receiverHolderName
        self.amount = amount
        self.description = description
        self.createdAt = createdAt
        self.status = status
    }
}
