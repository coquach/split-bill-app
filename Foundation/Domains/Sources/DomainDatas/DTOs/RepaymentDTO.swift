//
//  RepaymentDTO.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Domains
import Foundation

struct RepaymentDTO: Decodable, Sendable {
    let id: UUID
    let splitBillId: UUID
    let payerUserId: UUID?
    let transferTransactionId: UUID?
    let paymentMethod: PaymentMethod
    // Postgres `numeric`; see PostgresNumeric.
    let amount: PostgresNumeric
    let currency: String
    let payerDisplayName: String
    let note: String?
    let status: RepaymentStatus
    let idempotencyKey: String
    let paidAt: Date?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case splitBillId = "split_bill_id"
        case payerUserId = "payer_user_id"
        case transferTransactionId = "transfer_transaction_id"
        case paymentMethod = "payment_method"
        case amount
        case currency
        case payerDisplayName = "payer_display_name"
        case note
        case status
        case idempotencyKey = "idempotency_key"
        case paidAt = "paid_at"
        case createdAt = "created_at"
    }

    func toDomain() -> Repayment {
        Repayment(
            id: id,
            splitBillId: splitBillId,
            payerUserId: payerUserId,
            transferTransactionId: transferTransactionId,
            paymentMethod: paymentMethod,
            amount: Amount(amount.value),
            currency: currency,
            payerDisplayName: payerDisplayName,
            note: note,
            status: status,
            idempotencyKey: idempotencyKey,
            paidAt: paidAt,
            createdAt: createdAt
        )
    }
}

// create_qr_repayment's real return columns - not a repayments row, see QRRepaymentReceipt.
struct CreateQRRepaymentResultDTO: Decodable, Sendable {
    let id: UUID
    let splitBillId: UUID
    let transferTransactionId: UUID
    let amount: PostgresNumeric
    let paymentMethod: PaymentMethod
    let status: RepaymentStatus
    let paidSlots: Int
    let splitBillStatus: SplitBillStatus
    let paidAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case splitBillId = "split_bill_id"
        case transferTransactionId = "transfer_transaction_id"
        case amount
        case paymentMethod = "payment_method"
        case status
        case paidSlots = "paid_slots"
        case splitBillStatus = "split_bill_status"
        case paidAt = "paid_at"
    }

    func toDomain() -> QRRepaymentReceipt {
        QRRepaymentReceipt(
            id: id,
            splitBillId: splitBillId,
            transferTransactionId: transferTransactionId,
            amount: Amount(amount.value),
            paymentMethod: paymentMethod,
            status: status,
            paidSlots: paidSlots,
            splitBillStatus: splitBillStatus,
            paidAt: paidAt
        )
    }
}

struct CreateQRRepaymentRequest: Encodable, Sendable {
    let qrPayload: String
    let pin: String
    let note: String?
    let idempotencyKey: String
    enum CodingKeys: String, CodingKey {
        case qrPayload = "p_qr_payload"
        case pin = "p_pin"
        case note = "p_note"
        case idempotencyKey = "p_idempotency_key"
    }
    init(_ c: CreateQRRepaymentCommand) {
        qrPayload = c.qrPayload
        pin = c.pin
        note = c.note
        idempotencyKey = c.idempotencyKey
    }

    // p_note has no SQL default - same dropped-key risk as CreateTransferRequest.
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(qrPayload, forKey: .qrPayload)
        try c.encode(pin, forKey: .pin)
        try c.encode(note, forKey: .note)
        try c.encode(idempotencyKey, forKey: .idempotencyKey)
    }
}
