//
//  MockPinRepository.swift
//  SplitPay
//

#if DEBUG
    import Domains
    import Foundation

    /// Accepts any PIN except the magic failing one. UI tests type "123456".
    final nonisolated class MockPinRepository: IPinRepository, @unchecked Sendable {
        private let store: MockAppStore

        private(set) var setupPinCalls = 0
        private(set) var changePinCalls = 0
        private(set) var verifyPinCalls = 0

        init(store: MockAppStore) {
            self.store = store
        }

        func checkPinStatus() async throws -> Bool {
            store.pinIsSet
        }

        func setupPin(_: String) async throws -> Bool {
            setupPinCalls += 1
            return true
        }

        func changePin(oldPin: String, newPin _: String) async throws -> Bool {
            changePinCalls += 1
            return oldPin != UITestSeedData.failingPin
        }

        func verifyPin(_ pin: String) async throws -> Bool {
            verifyPinCalls += 1
            if UITestConfig.scenario == .otpFails {
                return false
            }
            return pin != UITestSeedData.failingPin
        }
    }
#endif
