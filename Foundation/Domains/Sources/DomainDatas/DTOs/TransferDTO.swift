//
//  TransferDTO.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Domains
import Foundation

struct TransferTransactionDTO: Decodable, Sendable {
    let id: UUID
    let transactionRef: String
    let status: TransferStatus
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

    func toDomain() -> TransferTransaction {
        TransferTransaction(
            id: id,
            transactionRef: transactionRef,
            status: status,
            amount: Int64(amount.value.rounded()),
            fee: Int64(fee.value.rounded()),
            description: description,
            completedAt: completedAt,
            createdAt: createdAt
        )
    }
}

struct TransferHistoryDTO: Decodable, Sendable {
    let id: UUID
    let transactionRef: String
    let direction: TransferDirection
    let senderUserId: UUID
    let senderWalletId: UUID
    let recipientUserId: UUID
    let recipientWalletId: UUID
    let amount: PostgresNumeric
    let fee: PostgresNumeric
    let description: String?
    let status: TransferStatus
    // Not returned by get_transfer_history; the wallet is VND-only.
    let currency: String?
    let counterpartyWalletNumber: String?
    let counterpartyName: String?
    let completedAt: Date?
    let createdAt: Date
    let isRepayment: Bool
    let repaymentId: UUID?
    let totalCount: Int64

    enum CodingKeys: String, CodingKey {
        case id
        case transactionRef = "transaction_ref"
        case direction
        case senderUserId = "sender_user_id"
        case senderWalletId = "sender_wallet_id"
        case recipientUserId = "recipient_user_id"
        case recipientWalletId = "recipient_wallet_id"
        case amount
        case fee
        case description
        case status
        case currency
        case counterpartyWalletNumber = "counterparty_wallet_number"
        case counterpartyName = "counterparty_name"
        case completedAt = "completed_at"
        case createdAt = "created_at"
        case isRepayment = "is_repayment"
        case repaymentId = "repayment_id"
        case totalCount = "total_count"
    }

    func toDomain() -> TransferHistory {
        TransferHistory(
            id: id,
            transactionRef: transactionRef,
            direction: direction,
            senderUserId: senderUserId,
            senderWalletId: senderWalletId,
            recipientUserId: recipientUserId,
            recipientWalletId: recipientWalletId,
            amount: Int64(amount.value.rounded()),
            fee: Int64(fee.value.rounded()),
            description: description,
            status: status,
            currency: currency ?? "VND",
            counterpartyWalletNumber: counterpartyWalletNumber,
            counterpartyName: counterpartyName,
            completedAt: completedAt,
            createdAt: createdAt,
            isRepayment: isRepayment,
            repaymentId: repaymentId,
            totalCount: totalCount
        )
    }
}

struct TransferDetailDTO: Decodable, Sendable {
    let id: UUID
    let transactionRef: String
    let senderUserId: UUID
    let recipientUserId: UUID
    let amount: PostgresNumeric
    let fee: PostgresNumeric
    let description: String?
    let status: TransferStatus
    let completedAt: Date?
    let createdAt: Date
    // Not returned by get_transfer_detail; the wallet is VND-only.
    let currency: String?
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
        case currency
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
            amount: Int64(amount.value.rounded()),
            fee: Int64(fee.value.rounded()),
            description: description,
            status: status,
            completedAt: completedAt,
            createdAt: createdAt,
            currency: currency ?? "VND",
            splitBillId: splitBillId,
            canCreateSplitBill: canCreateSplitBill,
            isSplitBillRepayment: isSplitBillRepayment
        )
    }
}

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

    init(_ c: CreateTransferCommand) {
        recipientWalletId = c.recipientWalletId
        amount = c.amount
        description = c.description
        pin = c.pin
        idempotencyKey = c.idempotencyKey
    }

    // Nil description would drop its key and break PostgREST's function-overload lookup.
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(recipientWalletId, forKey: .recipientWalletId)
        try c.encode(amount, forKey: .amount)
        try c.encode(description, forKey: .description)
        try c.encode(pin, forKey: .pin)
        try c.encode(idempotencyKey, forKey: .idempotencyKey)
    }
}

struct GetTransferHistoryRequest: Encodable, Sendable {
    let pPage: Int
    let pPageSize: Int
    let pType: String

    enum CodingKeys: String, CodingKey {
        case pPage = "p_page"
        case pPageSize = "p_page_size"
        case pType = "p_type"
    }

    init(page: Int, pageSize: Int, type: TransactionTypeFilter) {
        self.pPage = page
        self.pPageSize = pageSize
        self.pType = type.rawValue
    }
}

struct GetTransferDetailRequest: Encodable, Sendable {
    let pTransactionId: UUID

    enum CodingKeys: String, CodingKey {
        case pTransactionId = "p_transaction_id"
    }
}
