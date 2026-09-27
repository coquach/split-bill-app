//
//  IPinRepository.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Foundation

public struct PinVerificationResult: Sendable, Equatable {
    public let valid: Bool
    public let remainingAttempts: Int?
    public let lockedUntil: Date?

    public init(
        valid: Bool,
        remainingAttempts: Int?,
        lockedUntil: Date?
    ) {
        self.valid = valid
        self.remainingAttempts = remainingAttempts
        self.lockedUntil = lockedUntil
    }
}

public protocol IPinRepository: Sendable {
    func checkPinStatus() async throws -> Bool
    func setupPin(_ pin: String) async throws
    func changePin(oldPin: String, newPin: String) async throws
    func verifyPin(_ pin: String) async throws -> PinVerificationResult
}
