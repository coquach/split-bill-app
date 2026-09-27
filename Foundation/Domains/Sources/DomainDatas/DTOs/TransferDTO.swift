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
    let senderUserId: UUID
    let senderWalletId: UUID
    let recipientUserId: UUID
    let recipientWalletId: UUID
    let amount: Int64
    let fee: Int64
    let currency: String
    let description: String?
    let status: TransferStatus
    let transactionRef: String
    let idempotencyKey: String
    let completedAt: Date?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case senderUserId = "sender_user_id"
        case senderWalletId = "sender_wallet_id"
        case recipientUserId = "recipient_user_id"
        case recipientWalletId = "recipient_wallet_id"
        case amount
        case fee
        case currency
        case description
        case status
        case transactionRef = "transaction_ref"
        case idempotencyKey = "idempotency_key"
        case completedAt = "completed_at"
        case createdAt = "created_at"
    }

    func toDomain() -> TransferTransaction {
        TransferTransaction(
            id: id,
            senderUserId: senderUserId,
            senderWalletId: senderWalletId,
            recipientUserId: recipientUserId,
            recipientWalletId: recipientWalletId,
            amount: amount,
            fee: fee,
            currency: currency,
            description: description,
            status: status,
            transactionRef: transactionRef,
            idempotencyKey: idempotencyKey,
            completedAt: completedAt,
            createdAt: createdAt
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
}
