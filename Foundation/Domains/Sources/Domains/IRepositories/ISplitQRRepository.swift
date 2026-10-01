//
//  ISplitQRRepository.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Foundation

public protocol ISplitQRRepository: Sendable {
    func getQR(splitBillId: UUID) async throws -> SplitQRCode
    func decodeQR(payload: String) async throws -> SplitQRReview
}
