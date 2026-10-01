//
//  SplitQRCode.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Foundation

public struct SplitQRCode: Identifiable, Sendable, Equatable {
    public let id: UUID
    public let splitBillId: UUID
    public let walletId: UUID
    public let qrPayload: String
    public let isActive: Bool
    public let expiresAt: Date?
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: UUID,
        splitBillId: UUID,
        walletId: UUID,
        qrPayload: String,
        isActive: Bool,
        expiresAt: Date?,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.splitBillId = splitBillId
        self.walletId = walletId
        self.qrPayload = qrPayload
        self.isActive = isActive
        self.expiresAt = expiresAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct SplitQRReview: Sendable, Equatable {
    public let splitBillId: UUID
    public let title: String
    public let requesterName: String?
    public let amount: Int64
    public let currency: String
    public let perPersonAmount: Int64
    public let remainingSlots: Int

    public init(
        splitBillId: UUID,
        title: String,
        requesterName: String?,
        amount: Int64,
        currency: String,
        perPersonAmount: Int64,
        remainingSlots: Int
    ) {
        self.splitBillId = splitBillId
        self.title = title
        self.requesterName = requesterName
        self.amount = amount
        self.currency = currency
        self.perPersonAmount = perPersonAmount
        self.remainingSlots = remainingSlots
    }
}
