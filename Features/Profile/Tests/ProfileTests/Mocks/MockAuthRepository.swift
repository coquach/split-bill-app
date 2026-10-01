//
//  MockAuthRepository.swift
//  ProfileTests
//

import Domains
import Foundation

@MainActor
final class MockAuthRepository: IAuthRepository {
    var signOutError: Error?

    // Gates the sign-out call so a test can hold it mid-flight and probe
    // the view model's reentrancy guard.
    var holdSignOut = false
    private var signOutContinuation: CheckedContinuation<Void, Never>?

    func resumeSignOut() {
        signOutContinuation?.resume()
        signOutContinuation = nil
    }

    private(set) var signOutCalls = 0

    func signIn(email: String, password: String) async throws -> User {
        throw DomainError.unauthorized
    }

    func signUp(email: String, password: String, fullName: String, phone: String) async throws -> User {
        throw DomainError.unauthorized
    }

    func signOut() async throws {
        signOutCalls += 1
        if holdSignOut {
            await withCheckedContinuation { signOutContinuation = $0 }
        }
        if let signOutError { throw signOutError }
    }

    func validateSession() async -> Bool {
        false
    }

    var authStateChanges: AsyncStream<AuthState> {
        AsyncStream<AuthState>.makeStream().stream
    }
}
