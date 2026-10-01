//
//  WalletDTO.swift
//  DomainDatas
//
//  Created by Co Quach on 27/9/26.
//

import Domains
import Foundation

struct WalletDTO: Decodable, Sendable {
    let id: UUID
    let userId: UUID
    let walletNumber: String
    let walletHolderName: String
    let isDefault: Bool
    let status: WalletStatus

    /// `wallets.balance` is Postgres `numeric`. That never decodes straight
    /// into `Int64` — it arrives with a fractional part (`10000.00`), and
    /// sometimes quoted. `PostgresNumeric` absorbs both forms; the rounding
    /// to whole VND happens exactly once, in `toDomain()`.
    let balance: PostgresNumeric

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
            balance: Int64(balance.value.rounded()),
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

/// One row of `resolve_wallet_by_number`, declared server-side as
/// `RETURNS TABLE(wallet_id uuid, wallet_number text, holder_name text)`.
/// Two consequences: the keys are snake_case, and the response is a JSON
/// *array* of rows rather than a single object.
struct WalletRecipientDTO: Decodable, Sendable {
    let walletId: UUID
    let walletNumber: String
    let holderName: String

    enum CodingKeys: String, CodingKey {
        case walletId = "wallet_id"
        case walletNumber = "wallet_number"
        case holderName = "holder_name"
    }

    func toDomain() -> WalletRecipient {
        WalletRecipient(
            walletId: walletId,
            walletNumber: walletNumber,
            holderName: holderName
        )
    }
}
