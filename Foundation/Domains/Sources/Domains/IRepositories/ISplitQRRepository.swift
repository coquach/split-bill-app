import Foundation

//
//  ISplitQRRepository.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

public protocol ISplitQRRepository: Sendable {
    func generateQR(_ command: GenerateSplitQRCommand) async throws -> SplitQRCode
    func getQR(splitBillId: UUID) async throws -> SplitQRCode
    func decodeQR(payload: String) async throws -> SplitQRReview
}
