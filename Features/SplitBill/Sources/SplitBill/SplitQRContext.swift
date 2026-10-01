//
//  SplitQRContext.swift
//  SplitBill
//
//  Created by Dinh Long on 28/9/26.
//

import Domains
import Foundation


public struct SplitQRContext: Sendable, Equatable, Hashable {
    public let splitBillId: UUID
    public let title: String
    public let counterpartyName: String
    public let participantCount: Int
    public let perPersonAmount: Amount
    public let qrPayload: String

    public init(
        splitBillId: UUID,
        title: String,
        counterpartyName: String,
        participantCount: Int,
        perPersonAmount: Amount,
        qrPayload: String
    ) {
        self.splitBillId = splitBillId
        self.title = title
        self.counterpartyName = counterpartyName
        self.participantCount = participantCount
        self.perPersonAmount = perPersonAmount
        self.qrPayload = qrPayload
    }
}
