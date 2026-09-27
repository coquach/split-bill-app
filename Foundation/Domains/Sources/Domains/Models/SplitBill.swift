//
//  SplitBill.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Foundation

public struct SplitBill: Identifiable, Sendable, Equatable {
    public let id: UUID
    public let requesterId: UUID
    public let sourceTransferId: UUID
    public let title: String
    public let note: String?
    public let totalAmount: Int64
    public let currency: String
    public let participantCount: Int
    public let perPersonAmount: Int64
    public let requesterAmount: Int64
    public let requiredSlots: Int
    public let paidSlots: Int
    public let remainingSlots: Int
    public let status: SplitBillStatus
    public let expiresAt: Date?
    public let closedAt: Date?
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: UUID,
        requesterId: UUID,
        sourceTransferId: UUID,
        title: String,
        note: String?,
        totalAmount: Int64,
        currency: String,
        participantCount: Int,
        perPersonAmount: Int64,
        requesterAmount: Int64,
        requiredSlots: Int,
        paidSlots: Int,
        remainingSlots: Int,
        status: SplitBillStatus,
        expiresAt: Date?,
        closedAt: Date?,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.requesterId = requesterId
        self.sourceTransferId = sourceTransferId
        self.title = title
        self.note = note
        self.totalAmount = totalAmount
        self.currency = currency
        self.participantCount = participantCount
        self.perPersonAmount = perPersonAmount
        self.requesterAmount = requesterAmount
        self.requiredSlots = requiredSlots
        self.paidSlots = paidSlots
        self.remainingSlots = remainingSlots
        self.status = status
        self.expiresAt = expiresAt
        self.closedAt = closedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
