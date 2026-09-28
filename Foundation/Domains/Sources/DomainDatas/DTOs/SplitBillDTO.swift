import Domains
import Foundation

// MARK: - Split Bill record returned by create/update/close RPCs

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
    let status: SplitBillStatus
    let idempotencyKey: String?
    let expiresAt: Date?
    let closedAt: Date?
    let createdAt: Date
    let updatedAt: Date

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
        case idempotencyKey = "idempotency_key"
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
            remainingSlots: max(requiredSlots - paidSlots, 0),
            status: status,
            expiresAt: expiresAt,
            closedAt: closedAt,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// MARK: - RPC requests

struct CreateSplitBillRequest: Encodable, Sendable {
    let title: String
    let note: String?
    let participantCount: Int
    let sourceTransferId: UUID
    let idempotencyKey: String?
    let expiryDays: Int

    enum CodingKeys: String, CodingKey {
        case title = "p_title"
        case note = "p_note"
        case participantCount = "p_participant_count"
        case sourceTransferId = "p_source_transfer_id"
        case idempotencyKey = "p_idempotency_key"
        case expiryDays = "p_expiry_days"
    }

    init(_ command: CreateSplitBillCommand) {
        title = command.title
        note = command.note
        participantCount = command.participantCount
        sourceTransferId = command.sourceTransferId
        idempotencyKey = command.idempotencyKey
        expiryDays = command.expiryDays
    }
}

struct GetSplitBillsRequest: Encodable, Sendable {
    let role: SplitBillRoleFilter
    let status: SplitBillStatusFilter
    let page: Int
    let pageSize: Int

    enum CodingKeys: String, CodingKey {
        case role = "p_role"
        case status = "p_status"
        case page = "p_page"
        case pageSize = "p_page_size"
    }
}

struct GetSplitBillDetailRequest: Encodable, Sendable {
    let splitBillId: UUID

    enum CodingKeys: String, CodingKey {
        case splitBillId = "p_split_bill_id"
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

    init(_ command: UpdateSplitBillCommand) {
        splitBillId = command.splitBillId
        title = command.title
        note = command.note
        participantCount = command.participantCount
        expiresAt = command.expiresAt
    }
}

struct CloseSplitBillRequest: Encodable, Sendable {
    let splitBillId: UUID

    enum CodingKeys: String, CodingKey {
        case splitBillId = "p_split_bill_id"
    }
}

// MARK: - get_split_bills response

struct SplitBillListItemDTO: Decodable, Sendable {
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
    let isRequester: Bool
    let hasRepaid: Bool
    let totalCount: Int64

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
        case isRequester = "is_requester"
        case hasRepaid = "has_repaid"
        case totalCount = "total_count"
    }

    func toDomain() -> SplitBillListItem {
        SplitBillListItem(
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
            status: status,
            expiresAt: expiresAt,
            closedAt: closedAt,
            createdAt: createdAt,
            isRequester: isRequester,
            hasRepaid: hasRepaid
        )
    }
}

// MARK: - get_split_bill_detail response

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
    let qrId: UUID?
    let qrPayload: String?
    let qrImageURL: String?
    let qrIsActive: Bool?
    let qrExpiresAt: Date?
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
        case qrId = "qr_id"
        case qrPayload = "qr_payload"
        case qrImageURL = "qr_image_url"
        case qrIsActive = "qr_is_active"
        case qrExpiresAt = "qr_expires_at"
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
            qrId: qrId,
            qrPayload: qrPayload,
            qrImageURL: qrImageURL,
            qrIsActive: qrIsActive,
            qrExpiresAt: qrExpiresAt,
            isRequester: isRequester,
            hasRepaid: hasRepaid,
            canUpdate: canUpdate,
            canClose: canClose,
            canRepay: canRepay
        )
    }
}
