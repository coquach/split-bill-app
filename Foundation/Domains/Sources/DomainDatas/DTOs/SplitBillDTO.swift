import Domains
import Foundation

struct SplitBillDTO: Decodable, Sendable {
    let id: UUID
    let requesterId: UUID
    let sourceTransferId: UUID
    let title: String
    let note: String?
    // Postgres `numeric`; see PostgresNumeric for why these aren't Int64.
    let totalAmount: PostgresNumeric
    let currency: String
    let participantCount: Int
    let perPersonAmount: PostgresNumeric
    let requesterAmount: PostgresNumeric
    let requiredSlots: Int
    let paidSlots: Int
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
            totalAmount: Amount(totalAmount.value),
            currency: currency,
            participantCount: participantCount,
            perPersonAmount: Amount(perPersonAmount.value),
            requesterAmount: Amount(requesterAmount.value),
            requiredSlots: requiredSlots,
            paidSlots: paidSlots,
            remainingSlots: max(requiredSlots - paidSlots, 0),
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

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(splitBillId, forKey: .splitBillId)
        try container.encode(title, forKey: .title)
        try container.encode(note, forKey: .note)
        try container.encode(participantCount, forKey: .participantCount)
        try container.encode(expiresAt, forKey: .expiresAt)
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
    let totalAmount: PostgresNumeric
    let currency: String
    let participantCount: Int
    let perPersonAmount: PostgresNumeric
    let requesterAmount: PostgresNumeric
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
            totalAmount: Amount(totalAmount.value),
            currency: currency,
            participantCount: participantCount,
            perPersonAmount: Amount(perPersonAmount.value),
            requesterAmount: Amount(requesterAmount.value),
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

struct CreatedSplitQRDTO: Decodable, Sendable {
    let id: UUID?
    let splitBillId: UUID?
    let walletId: UUID?
    let qrPayload: String?
    let isActive: Bool?
    let expiresAt: Date?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id = "qr_id"
        case splitBillId = "qr_split_bill_id"
        case walletId = "qr_wallet_id"
        case qrPayload = "qr_payload"
        case isActive = "qr_is_active"
        case expiresAt = "qr_expires_at"
        case createdAt = "qr_created_at"
        case updatedAt = "qr_updated_at"
    }

    func toDomain() -> SplitQRCode? {
        guard
            let id,
            let splitBillId,
            let walletId,
            let qrPayload,
            let createdAt
        else {
            return nil
        }

        return SplitQRCode(
            id: id,
            splitBillId: splitBillId,
            walletId: walletId,
            qrPayload: qrPayload,
            isActive: isActive ?? true,
            expiresAt: expiresAt,
            createdAt: createdAt,
            updatedAt: updatedAt ?? createdAt
        )
    }
}

struct CreateSplitBillResultDTO: Decodable, Sendable {
    let bill: SplitBillDTO
    let qr: CreatedSplitQRDTO

    init(from decoder: Decoder) throws {
        bill = try SplitBillDTO(from: decoder)
        qr = try CreatedSplitQRDTO(from: decoder)
    }

    func toDomain() -> SplitBillCreation {
        SplitBillCreation(
            splitBill: bill.toDomain(),
            qrCode: qr.toDomain()
        )
    }
}

struct GetSplitBillsRequest: Encodable, Sendable {
    let role: String
    let status: String
    let page: Int
    let pageSize: Int

    enum CodingKeys: String, CodingKey {
        case role = "p_role"
        case status = "p_status"
        case page = "p_page"
        case pageSize = "p_page_size"
    }
}
