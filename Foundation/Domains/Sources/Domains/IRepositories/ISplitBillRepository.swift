//
//  ISplitBillRepository.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Foundation

public struct SplitBillListItem: Identifiable, Sendable, Equatable {
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
    public let status: SplitBillStatus
    public let expiresAt: Date?
    public let closedAt: Date?
    public let createdAt: Date
    public let isRequester: Bool
    public let hasRepaid: Bool

    public var remainingSlots: Int {
        max(requiredSlots - paidSlots, 0)
    }

    public init(
        id: UUID, requesterId: UUID, sourceTransferId: UUID, title: String, note: String?,
        totalAmount: Int64, currency: String, participantCount: Int, perPersonAmount: Int64,
        requesterAmount: Int64, requiredSlots: Int, paidSlots: Int, status: SplitBillStatus,
        expiresAt: Date?, closedAt: Date?, createdAt: Date, isRequester: Bool, hasRepaid: Bool
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
        self.status = status
        self.expiresAt = expiresAt
        self.closedAt = closedAt
        self.createdAt = createdAt
        self.isRequester = isRequester
        self.hasRepaid = hasRepaid
    }
}

public struct SplitBillPage: Sendable, Equatable {
    public let items: [SplitBillListItem]
    public let totalCount: Int64
    public let page: Int
    public let pageSize: Int

    public init(items: [SplitBillListItem], totalCount: Int64, page: Int, pageSize: Int) {
        self.items = items
        self.totalCount = totalCount
        self.page = page
        self.pageSize = pageSize
    }
}

public struct SplitBillDetail: Sendable, Equatable {
    public let splitBill: SplitBill
    public let transferStatus: TransferStatus
    public let transactionRef: String
    public let qrId: UUID?
    public let qrPayload: String?
    public let qrImageURL: String?
    public let qrIsActive: Bool?
    public let qrExpiresAt: Date?
    public let isRequester: Bool
    public let hasRepaid: Bool
    public let canUpdate: Bool
    public let canClose: Bool
    public let canRepay: Bool

    public init(
        splitBill: SplitBill, transferStatus: TransferStatus, transactionRef: String,
        qrId: UUID?, qrPayload: String?, qrImageURL: String?, qrIsActive: Bool?, qrExpiresAt: Date?,
        isRequester: Bool, hasRepaid: Bool, canUpdate: Bool, canClose: Bool, canRepay: Bool
    ) {
        self.splitBill = splitBill
        self.transferStatus = transferStatus
        self.transactionRef = transactionRef
        self.qrId = qrId
        self.qrPayload = qrPayload
        self.qrImageURL = qrImageURL
        self.qrIsActive = qrIsActive
        self.qrExpiresAt = qrExpiresAt
        self.isRequester = isRequester
        self.hasRepaid = hasRepaid
        self.canUpdate = canUpdate
        self.canClose = canClose
        self.canRepay = canRepay
    }
}

public protocol ISplitBillRepository: Sendable {
    func createSplitBill(_ command: CreateSplitBillCommand) async throws -> SplitBill

    func getSplitBills(
        role: SplitBillRoleFilter,
        status: SplitBillStatusFilter,
        page: Int,
        pageSize: Int
    ) async throws -> SplitBillPage

    func getSplitBill(id: UUID) async throws -> SplitBill

    func getSplitBillDetail(id: UUID) async throws -> SplitBillDetail

    func updateSplitBill(_ command: UpdateSplitBillCommand) async throws -> SplitBill

    func closeSplitBill(id: UUID) async throws -> SplitBill
}
