//
//  AccountRepository.swift
//  Domains
//
//  Created by Dinh Long on 25/9/26.
//

import Domains
import Foundation
import Supabase

private struct WalletLookupRow: Decodable {
    let walletNumber: String
    let walletHolderName: String

    enum CodingKeys: String, CodingKey {
        case walletNumber = "wallet_number"
        case walletHolderName = "wallet_holder_name"
    }
}

// Matches the resolve_wallet(p_wallet_number text) SQL function's parameter
// name exactly - PostgREST maps this JSON key to that argument.
private struct ResolveWalletParams: Encodable {
    let walletNumber: String

    enum CodingKeys: String, CodingKey {
        case walletNumber = "p_wallet_number"
    }
}

public final class AccountRepository: IAccountRepository {
    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }

    public func resolveAccount(accountNumber: String) async throws -> ResolvedAccount {
        let normalized = Self.normalize(accountNumber)

        do {
            // Plain `.from("wallets")` won't see another user's row - RLS
            // ("Users can view own wallets") restricts SELECT to
            // auth.uid() = user_id. Lookup goes through a SECURITY DEFINER
            // function instead, which only ever returns these two
            // non-sensitive columns regardless of row ownership.
            // maybeSingle() returns nil for zero matching rows instead of
            // throwing, so "not found" and "network trouble" stay cleanly
            // separated below.
            let row: WalletLookupRow? = try await client
                .rpc("resolve_wallet", params: ResolveWalletParams(walletNumber: normalized))
                .maybeSingle()
                .execute()
                .value

            guard let row else {
                throw AccountRepositoryError.notFound
            }

            return ResolvedAccount(accountNumber: row.walletNumber, holderName: row.walletHolderName)
        } catch let error as AccountRepositoryError {
            throw error
        } catch {
            throw AccountRepositoryError.network
        }
    }

    // Wallet numbers are stored as "SP-XXXXXXXX"; the UI only asks the
    // user to type the suffix, so this fills in the prefix if missing.
    private static func normalize(_ accountNumber: String) -> String {
        let trimmed = accountNumber.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        return trimmed.hasPrefix("SP-") ? trimmed : "SP-\(trimmed)"
    }
}
