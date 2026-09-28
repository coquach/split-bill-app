//
//  TransferRepository.swift
//  DomainDatas
//
//  Created by Co Quach on 27/9/26.
//

import Domains
import Foundation
import Supabase

public final class TransferRepository: ITransferRepository {
    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }

    public func createTransfer(
        _ command: CreateTransferCommand
    ) async throws -> TransferResult {
        do {
            // `create_transfer` is declared `RETURNS TABLE`, so PostgREST
            // hands back an array of rows even though this one always
            // produces exactly one.
            let rows: [CreateTransferResultDTO] =
                try await client
                .rpc(
                    "create_transfer",
                    params: CreateTransferRequest(command)
                )
                .execute()
                .value

            guard let row = rows.first else {
                // The RPC reports real problems (bad PIN, insufficient
                // balance) by raising, which surfaces as a PostgrestError.
                // An empty result means something changed server-side that
                // we don't model yet — don't silently treat it as success.
                throw DomainError.unknown(
                    code: nil,
                    message: "create_transfer returned no row."
                )
            }

            return row.toDomain()
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }

    public func getTransferDetail(id: UUID) async throws -> TransferDetail {
        do {
            let rows: [TransferDetailDTO] =
                try await client
                .rpc(
                    "get_transfer_detail",
                    params: GetTransferDetailRequest(transactionId: id)
                )
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
