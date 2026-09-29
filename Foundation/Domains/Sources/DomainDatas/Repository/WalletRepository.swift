//
//  WalletRepository.swift
//  DomainDatas
//
//  Created by Co Quach on 27/9/26.
//

import Domains
import Foundation

// Calls PostgREST directly over HTTPS - no Supabase SDK import.
public final class WalletRepository: IWalletRepository {
    private let client: SupabaseRestClient

    public init(client: SupabaseRestClient) {
        self.client = client
    }

    public func getDefaultWallet() async throws -> Wallet {
        do {
            let dto: WalletDTO = try await client.select(
                table: "wallets",
                filters: [
                    "is_default": "eq.true",
                    "status": "eq.\(WalletStatus.active.rawValue)",
                ],
                single: true
            )

            return dto.toDomain()
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }

    public func getWallets() async throws -> [Wallet] {
        do {
            let dtos: [WalletDTO] = try await client.select(
                table: "wallets",
                filters: ["status": "eq.\(WalletStatus.active.rawValue)"]
            )

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

            // RETURNS TABLE, so PostgREST sends an array even for one row.
            let rows: [WalletRecipientDTO] = try await client.rpc(
                "resolve_wallet_by_number",
                params: request
            )

            guard let row = rows.first else {
                throw DomainError.notFound
            }

            return row.toDomain()
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }
}
