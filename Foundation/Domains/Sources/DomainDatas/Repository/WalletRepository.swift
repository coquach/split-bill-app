//
//  WalletRepository.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Domains
import Foundation
import Supabase

public final class WalletRepository: IWalletRepository {
    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }

    public func getDefaultWallet() async throws -> Wallet {
        do {
            let dto: WalletDTO =
                try await client
                .from("wallets")
                .select()
                .eq("is_default", value: true)
                .eq("status", value: WalletStatus.active.rawValue)
                .single()
                .execute()
                .value

            return dto.toDomain()
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }

    public func getWallets() async throws -> [Wallet] {
        do {
            let dtos: [WalletDTO] =
                try await client
                .from("wallets")
                .select()
                .eq("status", value: WalletStatus.active.rawValue)
                .execute()
                .value

            return dtos.map { $0.toDomain() }
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }

    public func resolveWallet(walletNumber: String) async throws
        -> WalletRecipient
    {
        do {
            let request = ResolveWalletRequest(walletNumber: walletNumber)

            // `resolve_wallet_by_number` is declared `RETURNS TABLE`, so the
            // response is an array of rows. An unknown wallet number simply
            // yields zero rows — it isn't an error the RPC raises — which is
            // why "not found" is detected here rather than in the mapper.
            let rows: [WalletRecipientDTO] =
                try await client
                .rpc("resolve_wallet_by_number", params: request)
                .execute()
                .value

            guard let row = rows.first else {
                throw DomainError.notFound
            }

            return row.toDomain()
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }
}
