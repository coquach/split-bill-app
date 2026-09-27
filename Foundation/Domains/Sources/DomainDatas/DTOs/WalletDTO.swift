import Domains
//
//  WalletDTO.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//
import Foundation

struct WalletDTO: Decodable, Sendable {
    let id: UUID
    let userId: UUID
    let walletNumber: String
    let walletHolderName: String
    let isDefault: Bool
    let status: WalletStatus
    let balance: Int64
    let currency: String
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case walletNumber = "wallet_number"
        case walletHolderName = "wallet_holder_name"
        case isDefault = "is_default"
        case status
        case balance
        case currency
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    func toDomain() -> Wallet {
        Wallet(
            id: id,
            userId: userId,
            walletNumber: walletNumber,
            walletHolderName: walletHolderName,
            isDefault: isDefault,
            status: status,
            balance: balance,
            currency: currency,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

struct ResolveWalletRequest: Encodable, Sendable {
    let walletNumber: String

    enum CodingKeys: String, CodingKey {
        case walletNumber = "p_wallet_number"
    }
}

struct WalletRecipientDTO: Decodable, Sendable {
    public let walletNumber: String
    public let holderName: String
    enum CodingKeys: String, CodingKey {
        case walletNumber = "walletNumber"
        case holderName = "holderName"
    }
    func toDomain() -> WalletRecipient {
        WalletRecipient(walletNumber: walletNumber, holderName: holderName)
    }
}
