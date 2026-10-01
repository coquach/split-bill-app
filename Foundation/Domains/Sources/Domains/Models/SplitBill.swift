//
//  SplitBill.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Foundation

/// Money here is `Amount`, not `Int64`: the underlying columns are Postgres
/// `numeric`, and a per-person share divides to fractional dong (40 / 3 =
/// 13.333). Truncating that to a whole number would make the shares stop
/// summing back to the total.
public struct SplitBill: Identifiable, Sendable, Equatable {
    public let id: UUID
    public let requesterId: UUID
    public let sourceTransferId: UUID
    public let title: String
    public let note: String?
    public let totalAmount: Amount
    public let currency: String
    public let participantCount: Int
    public let perPersonAmount: Amount
    public let requesterAmount: Amount
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
        totalAmount: Amount,
        currency: String,
        participantCount: Int,
        perPersonAmount: Amount,
        requesterAmount: Amount,
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
