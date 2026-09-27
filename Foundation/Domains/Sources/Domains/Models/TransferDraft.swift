//
//  TransferDraft.swift
//  Domains
//
//  Created by Dinh Long on 26/9/26.
//

import Foundation

/// The transfer the user intends to make, collected on TransferInput and
/// carried forward through Confirm. Doesn't include the PIN — that's
/// entered separately on the OTP step, right before submission.
public struct TransferDraft: Sendable, Equatable, Hashable {
    public let receiverAccountNumber: String
    public let receiverHolderName: String
    public let amount: Amount
    public let description: String

    public init(
        receiverAccountNumber: String,
        receiverHolderName: String,
        amount: Amount,
        description: String
    ) {
        self.receiverAccountNumber = receiverAccountNumber
        self.receiverHolderName = receiverHolderName
        self.amount = amount
        self.description = description
    }
}
