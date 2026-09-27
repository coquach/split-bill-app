//
//  ISplitBillRepository.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Foundation

public struct SplitBillRecord: Sendable, Equatable {
    public let splitBill: SplitBill
    public let role: String?
    public init(splitBill: SplitBill, role: String?) {
        self.splitBill = splitBill
        self.role = role
    }
}

public struct SplitBillDashboard: Sendable, Equatable {
    public let splitBillId: UUID
    public let title: String
    public let totalAmount: Int64
    public let currency: String
    public let participantCount: Int
    public let perPersonAmount: Int64
    public let requesterAmount: Int64
    public let requiredSlots: Int
    public let paidSlots: Int
    public let remainingSlots: Int
    public let status: SplitBillStatus
    public let repayments: [Repayment]
    public init(
        splitBillId: UUID,
        title: String,
        totalAmount: Int64,
        currency: String,
        participantCount: Int,
        perPersonAmount: Int64,
        requesterAmount: Int64,
        requiredSlots: Int,
        paidSlots: Int,
        remainingSlots: Int,
        status: SplitBillStatus,
        repayments: [Repayment]
    ) {
        self.splitBillId = splitBillId
        self.title = title
        self.totalAmount = totalAmount
        self.currency = currency
        self.participantCount = participantCount
        self.perPersonAmount = perPersonAmount
        self.requesterAmount = requesterAmount
        self.requiredSlots = requiredSlots
        self.paidSlots = paidSlots
        self.remainingSlots = remainingSlots
        self.status = status
        self.repayments = repayments
    }
}

public struct SplitBillDetail: Sendable, Equatable {
    public let splitBill: SplitBill
    public let transferStatus: TransferStatus
    public let transactionRef: String
    public let isRequester: Bool
    public let hasRepaid: Bool
    public let canUpdate: Bool
    public let canClose: Bool
    public let canRepay: Bool

    public init(
        splitBill: SplitBill,
        transferStatus: TransferStatus,
        transactionRef: String,
        isRequester: Bool,
        hasRepaid: Bool,
        canUpdate: Bool,
        canClose: Bool,
        canRepay: Bool
    ) {
        self.splitBill = splitBill
        self.transferStatus = transferStatus
        self.transactionRef = transactionRef
        self.isRequester = isRequester
        self.hasRepaid = hasRepaid
        self.canUpdate = canUpdate
        self.canClose = canClose
        self.canRepay = canRepay
    }
}

public protocol ISplitBillRepository: Sendable {
    func createSplitBill(_ command: CreateSplitBillCommand) async throws
        -> SplitBill
    func getSplitBills() async throws -> [SplitBill]
    func getSplitBill(id: UUID) async throws -> SplitBill
    func getSplitBillDetail(id: UUID) async throws -> SplitBillDetail
    func updateSplitBill(_ command: UpdateSplitBillCommand) async throws
        -> SplitBill
    func closeSplitBill(id: UUID) async throws -> SplitBill
    func cancelSplitBill(id: UUID) async throws -> SplitBill
    func getDashboard(id: UUID) async throws -> SplitBillDashboard
    func getMySplitBillRecords() async throws -> [SplitBillRecord]
}
