import Domains
import Foundation

struct SplitBillDTO: Decodable, Sendable {
    let id: UUID
    let requesterId: UUID
    let sourceTransferId: UUID
    let title: String
    let note: String?
    let totalAmount: Int64
    let currency: String
    let participantCount: Int
    let perPersonAmount: Int64
    let requesterAmount: Int64
    let requiredSlots: Int
    let paidSlots: Int
    let remainingSlots: Int
    let status: SplitBillStatus
    let expiresAt: Date?
    let closedAt: Date?
    let createdAt: Date
    let updatedAt: Date?
    enum CodingKeys: String, CodingKey {
        case id, title, note, currency, status
        case requesterId = "requester_id"
        case sourceTransferId = "source_transfer_id"
        case totalAmount = "total_amount"
        case participantCount = "participant_count"
        case perPersonAmount = "per_person_amount"
        case requesterAmount = "requester_amount"
        case requiredSlots = "required_slots"
        case paidSlots = "paid_slots"
        case remainingSlots = "remaining_slots"
        case expiresAt = "expires_at"
        case closedAt = "closed_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    func toDomain() -> SplitBill {
        SplitBill(
            id: id,
            requesterId: requesterId,
            sourceTransferId: sourceTransferId,
            title: title,
            note: note,
            totalAmount: totalAmount,
            currency: currency,
            participantCount: participantCount,
            perPersonAmount: perPersonAmount,
            requesterAmount: requesterAmount,
            requiredSlots: requiredSlots,
            paidSlots: paidSlots,
            remainingSlots: remainingSlots,
            status: status,
            expiresAt: expiresAt,
            closedAt: closedAt,
            createdAt: createdAt,
            updatedAt: updatedAt ?? createdAt
        )
    }
}

struct CreateSplitBillRequest: Encodable, Sendable {
    let title: String?
    let note: String?
    let participantCount: Int?
    let sourceTransferId: UUID?
    let idempotencyKey: String?
    let expiryDays: Int?
    enum CodingKeys: String, CodingKey {
        case title = "p_title"
        case note = "p_note"
        case participantCount = "p_participant_count"
        case sourceTransferId = "p_source_transfer_id"
        case idempotencyKey = "p_idempotency_key"
        case expiryDays = "p_expiry_days"
    }
    init(_ c: CreateSplitBillCommand) {
        title = c.title
        note = c.note
        participantCount = c.participantCount
        sourceTransferId = c.sourceTransferId
        idempotencyKey = c.idempotencyKey
        expiryDays = c.expiryDays
    }
}

struct UpdateSplitBillRequest: Encodable, Sendable {
    let splitBillId: UUID
    let title: String?
    let note: String?
    let participantCount: Int?
    let expiresAt: Date?
    enum CodingKeys: String, CodingKey {
        case splitBillId = "p_split_bill_id"
        case title = "p_title"
        case note = "p_note"
        case participantCount = "p_participant_count"
        case expiresAt = "p_expires_at"
    }
    init(_ c: UpdateSplitBillCommand) {
        splitBillId = c.splitBillId
        title = c.title
        note = c.note
        participantCount = c.participantCount
        expiresAt = c.expiresAt
    }
}

struct SplitBillDashboardDTO: Decodable, Sendable {
    let splitBillId: UUID
    let title: String
    let totalAmount: Int64
    let currency: String
    let participantCount: Int
    let perPersonAmount: Int64
    let requesterAmount: Int64
    let requiredSlots: Int
    let paidSlots: Int
    let remainingSlots: Int
    let status: SplitBillStatus
    let repayments: [RepaymentDTO]
    enum CodingKeys: String, CodingKey {
        case splitBillId = "split_bill_id"
        case title
        case totalAmount = "total_amount"
        case currency
        case participantCount = "participant_count"
        case perPersonAmount = "per_person_amount"
        case requesterAmount = "requester_amount"
        case requiredSlots = "required_slots"
        case paidSlots = "paid_slots"
        case remainingSlots = "remaining_slots"
        case status, repayments
    }
    func toDomain() -> SplitBillDashboard {
        SplitBillDashboard(
            splitBillId: splitBillId,
            title: title,
            totalAmount: totalAmount,
            currency: currency,
            participantCount: participantCount,
            perPersonAmount: perPersonAmount,
            requesterAmount: requesterAmount,
            requiredSlots: requiredSlots,
            paidSlots: paidSlots,
            remainingSlots: remainingSlots,
            status: status,
            repayments: repayments.map { $0.toDomain() }
        )
    }
}

struct SplitBillRecordDTO: Decodable, Sendable {
    let splitBill: SplitBillDTO
    let role: String?
    enum CodingKeys: String, CodingKey {
        case splitBill = "split_bill"
        case role
    }
    func toDomain() -> SplitBillRecord {
        SplitBillRecord(splitBill: splitBill.toDomain(), role: role)
    }
}

struct SplitBillDetailDTO: Decodable, Sendable {
    let id: UUID
    let requesterId: UUID
    let sourceTransferId: UUID
    let title: String
    let note: String?
    let totalAmount: Int64
    let currency: String
    let participantCount: Int
    let perPersonAmount: Int64
    let requesterAmount: Int64
    let requiredSlots: Int
    let paidSlots: Int
    let status: SplitBillStatus
    let expiresAt: Date?
    let closedAt: Date?
    let createdAt: Date
    let transferStatus: TransferStatus
    let transactionRef: String
    let isRequester: Bool
    let hasRepaid: Bool
    let canUpdate: Bool
    let canClose: Bool
    let canRepay: Bool

    enum CodingKeys: String, CodingKey {
        case id, title, note, currency, status
        case requesterId = "requester_id"
        case sourceTransferId = "source_transfer_id"
        case totalAmount = "total_amount"
        case participantCount = "participant_count"
        case perPersonAmount = "per_person_amount"
        case requesterAmount = "requester_amount"
        case requiredSlots = "required_slots"
        case paidSlots = "paid_slots"
        case expiresAt = "expires_at"
        case closedAt = "closed_at"
        case createdAt = "created_at"
        case transferStatus = "transfer_status"
        case transactionRef = "transaction_ref"
        case isRequester = "is_requester"
        case hasRepaid = "has_repaid"
        case canUpdate = "can_update"
        case canClose = "can_close"
        case canRepay = "can_repay"
    }

    func toDomain() -> SplitBillDetail {
        let bill = SplitBill(
            id: id,
            requesterId: requesterId,
            sourceTransferId: sourceTransferId,
            title: title,
            note: note,
            totalAmount: totalAmount,
            currency: currency,
            participantCount: participantCount,
            perPersonAmount: perPersonAmount,
            requesterAmount: requesterAmount,
            requiredSlots: requiredSlots,
            paidSlots: paidSlots,
            remainingSlots: max(requiredSlots - paidSlots, 0),
            status: status,
            expiresAt: expiresAt,
            closedAt: closedAt,
            createdAt: createdAt,
            updatedAt: createdAt
        )
        return SplitBillDetail(
            splitBill: bill,
            transferStatus: transferStatus,
            transactionRef: transactionRef,
            isRequester: isRequester,
            hasRepaid: hasRepaid,
            canUpdate: canUpdate,
            canClose: canClose,
            canRepay: canRepay
        )
    }
}
