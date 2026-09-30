//
//  MockPinRepository.swift
//  ProfileTests
//

import Domains
import Foundation

final class MockPinRepository: IPinRepository, @unchecked Sendable {
    var hasPin = false
    var setupResult = true
    var changeResult = true
    var verifyResult = true
    var error: Error?

    // Gates the setup call so a test can hold it mid-flight and probe
    // the view model's reentrancy guard.
    var holdSetupPin = false
    private var setupContinuation: CheckedContinuation<Void, Never>?

    func resumeSetupPin() {
        setupContinuation?.resume()
        setupContinuation = nil
    }

    private(set) var checkPinStatusCalls = 0
    private(set) var setupPinCalls = 0
    private(set) var lastSetupPin: String?
    private(set) var changePinCalls = 0
    private(set) var lastOldPin: String?
    private(set) var lastNewPin: String?
    private(set) var verifyPinCalls = 0

    func checkPinStatus() async throws -> Bool {
        checkPinStatusCalls += 1
        if let error { throw error }
        return hasPin
    }

    func setupPin(_ pin: String) async throws -> Bool {
        setupPinCalls += 1
        lastSetupPin = pin
        if holdSetupPin {
            await withCheckedContinuation { setupContinuation = $0 }
        }
        if let error { throw error }
        return setupResult
    }

    func changePin(oldPin: String, newPin: String) async throws -> Bool {
        changePinCalls += 1
        lastOldPin = oldPin
        lastNewPin = newPin
        if let error { throw error }
        return changeResult
    }

    func verifyPin(_ pin: String) async throws -> Bool {
        verifyPinCalls += 1
        if let error { throw error }
        return verifyResult
    }
}
