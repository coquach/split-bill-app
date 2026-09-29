//
//  TransferRepository.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Domains
import Foundation

public final class TransferRepository: ITransferRepository {
    private let client: SupabaseRestClient

    public init(client: SupabaseRestClient) {
        self.client = client
    }

    public func createTransfer(
        _ command: CreateTransferCommand
    ) async throws -> TransferTransaction {
        do {
            // RETURNS TABLE, so PostgREST sends an array even for one row.
            let rows: [TransferTransactionDTO] = try await client.rpc(
                "create_transfer",
                params: CreateTransferRequest(command)
            )

            guard let dto = rows.first else {
                throw DomainError.unknown(
                    code: nil,
                    message: "create_transfer returned no row."
                )
            }

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
            let dtos: [TransferHistoryDTO] = try await client.rpc(
                "get_transfer_history",
                params: GetTransferHistoryRequest(
                    page: page,
                    pageSize: pageSize,
                    type: filter
                )
            )

            return dtos.map { $0.toDomain() }
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }

    public func getTransfer(id: UUID) async throws -> TransferDetail {
        do {
            // RETURNS TABLE, so PostgREST sends an array even for one row.
            let rows: [TransferDetailDTO] = try await client.rpc(
                "get_transfer_detail",
                params: GetTransferDetailRequest(pTransactionId: id)
            )

            guard let dto = rows.first else {
                throw DomainError.notFound
            }

            return dto.toDomain()
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }
}
