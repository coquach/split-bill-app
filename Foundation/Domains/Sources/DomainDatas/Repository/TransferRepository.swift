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
            let rows: [CreateTransferResultDTO] =
                try await client
                .rpc(
                    "create_transfer",
                    params: CreateTransferRequest(command)
                )
                .execute()
                .value

            guard let row = rows.first else {
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
