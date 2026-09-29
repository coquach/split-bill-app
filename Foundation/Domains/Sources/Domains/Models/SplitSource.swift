//
//  SplitSource.swift
//  Domains
//
//  Created by Dinh Long on 28/9/26.
//

import Foundation

public struct SplitSource: Identifiable, Sendable, Equatable, Hashable {

    public var id: UUID { transferId }

    public let transferId: UUID
    public let title: String
    public let counterpartyName: String
    public let date: Date
    public let totalAmount: Amount

    public init(
        transferId: UUID,
        title: String,
        counterpartyName: String,
        date: Date,
        totalAmount: Amount
    ) {
        self.transferId = transferId
        self.title = title
        self.counterpartyName = counterpartyName
        self.date = date
        self.totalAmount = totalAmount
    }
}
