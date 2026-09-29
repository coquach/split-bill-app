//
//  RepaymentRepository.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Domains
import Foundation
import Supabase

public final class RepaymentRepository: IRepaymentRepository {
    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }

    public func createQRRepayment(
        _ command: CreateQRRepaymentCommand
    ) async throws -> Repayment {
        do {
            // RETURNS TABLE, so PostgREST sends an array even for one row.
            let rows: [RepaymentDTO] =
                try await client
                .rpc(
                    "create_qr_repayment",
                    params: CreateQRRepaymentRequest(command)
                )
                .execute()
                .value

            guard let dto = rows.first else {
                throw DomainError.unknown(
                    code: nil,
                    message: "create_qr_repayment returned no row."
                )
            }

            return dto.toDomain()
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }

    public func getRepayments(
        splitBillId: UUID
    ) async throws -> [Repayment] {
        do {
            let dtos: [RepaymentDTO] =
                try await client
                .from("repayments")
                .select()
                .eq("split_bill_id", value: splitBillId.uuidString)
                .order("paid_at", ascending: false)
                .execute()
                .value

            return dtos.map { $0.toDomain() }
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }

    public func getMyRepaymentRecords() async throws -> [RepaymentRecord] {
        do {
            let dtos: [RepaymentRecordDTO] =
                try await client
                .from("my_repayment_records")
                .select()
                .execute()
                .value

            return dtos.map { $0.toDomain() }
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }
}
