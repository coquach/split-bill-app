//
//  TransferDTO.swift
//  DomainDatas
//
//  Created by Co Quach on 27/9/26.
//

import Domains
import Foundation

// MARK: - create_transfer

struct CreateTransferRequest: Encodable, Sendable {
    let recipientWalletId: UUID
    let amount: Int64
    let description: String?
    let pin: String
    let idempotencyKey: String

    enum CodingKeys: String, CodingKey {
        case recipientWalletId = "p_recipient_wallet_id"
        case amount = "p_amount"
        case description = "p_description"
        case pin = "p_pin"
        case idempotencyKey = "p_idempotency_key"
    }

    init(_ command: CreateTransferCommand) {
        recipientWalletId = command.recipientWalletId
        amount = command.amount
        description = command.description
        pin = command.pin
        idempotencyKey = command.idempotencyKey
    }
}

/// `create_transfer` returns `RETURNS TABLE(id, transaction_ref, status,
/// amount, fee, description, completed_at, created_at)` — eight columns, not
/// the full `transfer_transactions` row. In particular there is no
/// `currency`, no `sender_*`/`recipient_*` ids and no `idempotency_key`, so
/// this cannot be decoded as a whole-row DTO.
///
/// `amount` and `fee` are `numeric`; see `PostgresNumeric` for why they
/// aren't decoded as a plain number.
struct CreateTransferResultDTO: Decodable, Sendable {
    let id: UUID
    let transactionRef: String
    let status: String
    let amount: PostgresNumeric
    let fee: PostgresNumeric
    let description: String?
    let completedAt: Date?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case transactionRef = "transaction_ref"
        case status
        case amount
        case fee
        case description
        case completedAt = "completed_at"
        case createdAt = "created_at"
    }

    func toDomain() -> TransferResult {
        TransferResult(
            id: id,
            transactionRef: transactionRef,
            status: TransferStatus(fromDatabase: status),
            amount: Amount(amount.value),
            fee: Amount(fee.value),
            description: description,
            completedAt: completedAt,
            createdAt: createdAt
        )
    }
}

// MARK: - get_transfer_detail

struct GetTransferDetailRequest: Encodable, Sendable {
    let transactionId: UUID

    enum CodingKeys: String, CodingKey {
        case transactionId = "p_transaction_id"
    }
}

/// One row of `get_transfer_detail`. Also a `RETURNS TABLE`, so also an
/// array on the wire.
struct TransferDetailDTO: Decodable, Sendable {
    let id: UUID
    let transactionRef: String
    let senderUserId: UUID
    let recipientUserId: UUID
    let amount: PostgresNumeric
    let fee: PostgresNumeric
    let description: String?
    let status: String
    let completedAt: Date?
    let createdAt: Date
    let splitBillId: UUID?
    let canCreateSplitBill: Bool
    let isSplitBillRepayment: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case transactionRef = "transaction_ref"
        case senderUserId = "sender_user_id"
        case recipientUserId = "recipient_user_id"
        case amount
        case fee
        case description
        case status
        case completedAt = "completed_at"
        case createdAt = "created_at"
        case splitBillId = "split_bill_id"
        case canCreateSplitBill = "can_create_split_bill"
        case isSplitBillRepayment = "is_split_bill_repayment"
    }

    func toDomain() -> TransferDetail {
        TransferDetail(
            id: id,
            transactionRef: transactionRef,
            senderUserId: senderUserId,
            recipientUserId: recipientUserId,
            amount: Amount(amount.value),
            fee: Amount(fee.value),
            description: description,
            status: TransferStatus(fromDatabase: status),
            completedAt: completedAt,
            createdAt: createdAt,
            splitBillId: splitBillId,
            canCreateSplitBill: canCreateSplitBill,
            isSplitBillRepayment: isSplitBillRepayment
        )
    }
}
