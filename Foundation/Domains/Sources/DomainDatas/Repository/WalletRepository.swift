//
//  WalletRepository.swift
//  DomainDatas
//
//  Created by Dinh Long on 26/9/26.
//

import Domains
import Foundation
import Supabase

private struct WalletBalanceRow: Decodable {
    let balance: Double
}

public final class WalletRepository: IWalletRepository {
    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }

    public func fetchBalance() async throws -> Amount {
        guard let userID = client.auth.currentUser?.id else {
            throw AccountRepositoryError.unknown
        }

        let row: WalletBalanceRow = try await client
            .from("wallets")
            .select("balance")
            .eq("user_id", value: userID)
            .eq("is_default", value: true)
            .single()
            .execute()
            .value

        return Amount(row.balance)
    }
}
