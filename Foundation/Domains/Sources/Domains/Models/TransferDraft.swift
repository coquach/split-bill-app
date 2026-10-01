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
///
/// `receiverWalletId` comes from the account lookup, not from anything the
/// user typed. It's the only receiver field the backend actually reads; the
/// account number and holder name are here purely so Confirm, Success and
/// Transaction Detail have something to display.
public struct TransferDraft: Sendable, Equatable, Hashable {
    public let receiverWalletId: UUID
    public let receiverAccountNumber: String
    public let receiverHolderName: String
    public let amount: Amount
    public let description: String

    public init(
        receiverWalletId: UUID,
        receiverAccountNumber: String,
        receiverHolderName: String,
        amount: Amount,
        description: String
    ) {
        self.receiverWalletId = receiverWalletId
        self.receiverAccountNumber = receiverAccountNumber
        self.receiverHolderName = receiverHolderName
        self.amount = amount
        self.description = description
    }
}
