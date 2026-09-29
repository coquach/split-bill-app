//
//  TransferRepository.swift
//  Domains
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
    ) async throws -> TransferTransaction {
        do {
            let dto: TransferTransactionDTO =
                try await client
                .rpc(
                    "create_transfer",
                    params: CreateTransferRequest(command)
                )
                .execute()
                .value

            return dto.toDomain()
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }

    public func getTransfers(
        page: Int = 1,
        pageSize: Int = 20,
        filter: TransactionTypeFilter = .all
    ) async throws -> [TransferHistory] {
        do {
            let dtos: [TransferHistoryDTO] =
                try await client
                .rpc(
                    "get_transfer_history",
                    params: GetTransferHistoryRequest(
                        page: page,
                        pageSize: pageSize,
                        type: filter
                    )
                )
                .execute()
                .value

            return dtos.map { $0.toDomain() }
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }

    public func getTransfer(id: UUID) async throws -> TransferDetail {
        do {
            let dto: TransferDetailDTO =
                try await client
                .rpc(
                    "get_transfer_detail",
                    params: GetTransferDetailRequest(pTransactionId: id)
                )
                .execute()
                .value

            return dto.toDomain()
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }
}
