//
//  SplitQRRepository.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Domains
import Foundation
import Supabase

public final class SplitQRRepository: ISplitQRRepository {
    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }

    public func getQR(splitBillId: UUID) async throws -> SplitQRCode {
        do {
            let dtos: [SplitQRCodeDTO] =
                try await client
                .rpc(
                    "get_split_qr",
                    params: GetSplitQRRequest(splitBillId: splitBillId)
                )
                .execute()
                .value
            guard let dto = dtos.first else {
                throw DomainError.unknown(
                    code: "QR_NOT_FOUND",
                    message: "Split Bill QR not found."
                )
            }
            return dto.toDomain()
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }

    public func decodeQR(payload: String) async throws -> SplitQRReview {
        do {
            let request = DecodeSplitQRRequest(qrPayload: payload)

            // RETURNS TABLE, so PostgREST sends an array even for one row.
            let rows: [SplitQRReviewDTO] =
                try await client
                .rpc(
                    "decode_split_qr",
                    params: request
                )
                .execute()
                .value

            guard let dto = rows.first else {
                throw DomainError.notFound
            }

            return dto.toDomain()
        } catch {
            throw RepositoryErrorMapper.map(error)
        }
    }
}
