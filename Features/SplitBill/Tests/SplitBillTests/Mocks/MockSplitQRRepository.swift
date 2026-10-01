//
//  MockSplitQRRepository.swift
//  SplitBillTests
//

import Domains
import Foundation

final class MockSplitQRRepository: ISplitQRRepository, @unchecked Sendable {
    var qr: SplitQRCode?
    var review: SplitQRReview?
    var error: Error?

    private(set) var getQRCalls = 0
    private(set) var lastQRSplitBillId: UUID?
    private(set) var decodeQRCalls = 0
    private(set) var lastDecodedPayload: String?

    func getQR(splitBillId: UUID) async throws -> SplitQRCode {
        getQRCalls += 1
        lastQRSplitBillId = splitBillId
        if let error { throw error }
        guard let qr else { throw DomainError.notFound }
        return qr
    }

    func decodeQR(payload: String) async throws -> SplitQRReview {
        decodeQRCalls += 1
        lastDecodedPayload = payload
        if let error { throw error }
        guard let review else { throw DomainError.notFound }
        return review
    }
}
