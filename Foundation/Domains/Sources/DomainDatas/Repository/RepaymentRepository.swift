//
//  RepaymentRepository.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Domains
import Foundation

public final class RepaymentRepository: IRepaymentRepository {
    private let client: SupabaseRestClient

    public init(client: SupabaseRestClient) {
        self.client = client
    }

    public func createQRRepayment(
        _ command: CreateQRRepaymentCommand
    ) async throws -> QRRepaymentReceipt {
        do {
            // RETURNS TABLE, so PostgREST sends an array even for one row.
            let rows: [CreateQRRepaymentResultDTO] = try await client.rpc(
                "create_qr_repayment",
                params: CreateQRRepaymentRequest(command)
            )

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
            let dtos: [RepaymentDTO] = try await client.select(
                table: "repayments",
                filters: ["split_bill_id": "eq.\(splitBillId.uuidString)"],
                order: "paid_at.desc"
            )

            return dtos.map { $0.toDomain() }
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }
}
