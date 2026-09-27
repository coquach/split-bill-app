//
//  QRDTO.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Domains
import Foundation

struct SplitQRCodeDTO: Decodable, Sendable {
    let id: UUID
    let splitBillId: UUID
    let walletId: UUID
    let qrPayload: String
    let isActive: Bool
    let expiresAt: Date?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case splitBillId = "split_bill_id"
        case walletId = "wallet_id"
        case qrPayload = "qr_payload"
        case isActive = "is_active"
        case expiresAt = "expires_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    func toDomain() -> SplitQRCode {
        SplitQRCode(
            id: id,
            splitBillId: splitBillId,
            walletId: walletId,
            qrPayload: qrPayload,
            isActive: isActive,
            expiresAt: expiresAt,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

public struct GetSplitQRRequest: Encodable, Sendable {
    let splitBillId: UUID
    enum CodingKeys: String, CodingKey { case splitBillId = "p_split_bill_id" }
    public init(splitBillId: UUID) { self.splitBillId = splitBillId }
}

struct GenerateSplitQRRequest: Encodable, Sendable {
    let splitBillId: UUID
    enum CodingKeys: String, CodingKey { case splitBillId = "p_split_bill_id" }
    init(_ c: GenerateSplitQRCommand) { splitBillId = c.splitBillId }
}

struct SplitQRReviewDTO: Decodable, Sendable {
    let splitBillId: UUID
    let title: String
    let requesterName: String?
    let amount: Int64
    let currency: String
    let perPersonAmount: Int64
    let remainingSlots: Int

    enum CodingKeys: String, CodingKey {
        case splitBillId = "split_bill_id"
        case title
        case requesterName = "requester_name"
        case amount
        case currency
        case perPersonAmount = "per_person_amount"
        case remainingSlots = "remaining_slots"
    }

    func toDomain() -> SplitQRReview {
        SplitQRReview(
            splitBillId: splitBillId,
            title: title,
            requesterName: requesterName,
            amount: amount,
            currency: currency,
            perPersonAmount: perPersonAmount,
            remainingSlots: remainingSlots
        )
    }
}

public struct DecodeSplitQRRequest: Encodable, Sendable {
    let qrPayload: String

    enum CodingKeys: String, CodingKey {
        case qrPayload = "p_qr_payload"
    }
}
