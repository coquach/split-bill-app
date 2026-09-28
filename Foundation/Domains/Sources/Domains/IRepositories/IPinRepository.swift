//
//  IPinRepository.swift
//  Domains
//
//  Created by Co Quach on 27/9/26.
//

import Foundation

/// Every one of these maps to an RPC that returns a bare `boolean`. There is
/// deliberately no richer result type: the backend doesn't currently report
/// remaining attempts or a lockout deadline, and inventing fields the server
/// never sends would just be a lie the UI then has to handle.
public protocol IPinRepository: Sendable {
    func checkPinStatus() async throws -> Bool
    func setupPin(_ pin: String) async throws -> Bool
    func changePin(currentPin: String, newPin: String) async throws -> Bool
    func verifyPin(_ pin: String) async throws -> Bool
}
