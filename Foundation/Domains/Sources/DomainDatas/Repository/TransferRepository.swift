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

    public func getTransfers() async throws -> [TransferTransaction] {
        do {
            let dtos: [TransferTransactionDTO] =
                try await client
                .from("transfer_transactions")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value

            return dtos.map { $0.toDomain() }
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }

    public func getTransfer(id: UUID) async throws -> TransferTransaction {
        do {
            let dto: TransferTransactionDTO =
                try await client
                .from("transfer_transactions")
                .select()
                .eq("id", value: id.uuidString)
                .single()
                .execute()
                .value

            return dto.toDomain()
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }
}
