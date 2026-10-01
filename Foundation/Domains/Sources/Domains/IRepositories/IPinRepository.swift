//
//  IPinRepository.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Foundation

public protocol IPinRepository: Sendable {
    func checkPinStatus() async throws -> Bool

    func setupPin(_ pin: String) async throws -> Bool

    func changePin(
        oldPin: String,
        newPin: String
    ) async throws -> Bool

    func verifyPin(_ pin: String) async throws -> Bool
}
