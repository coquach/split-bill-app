//
//  SplitQRRepository.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Domains
import Foundation

public final class SplitQRRepository: ISplitQRRepository {
    private let client: SupabaseRestClient

    public init(client: SupabaseRestClient) {
        self.client = client
    }

    public func getQR(splitBillId: UUID) async throws -> SplitQRCode {
        do {
            let dtos: [SplitQRCodeDTO] = try await client.rpc(
                "get_split_qr",
                params: GetSplitQRRequest(splitBillId: splitBillId)
            )
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
            let rows: [SplitQRReviewDTO] = try await client.rpc(
                "decode_split_qr",
                params: request
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
