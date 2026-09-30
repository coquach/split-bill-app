//
//  MockAuthRepository.swift
//  AuthenticationTests
//

import Authentication
import Domains
import Foundation

@MainActor
final class MockAuthRepository: IAuthRepository {

    var signInResult: Result<User, Error> = .success(makeUser())
    var signUpResult: Result<User, Error> = .success(makeUser())
    var signOutResult: Result<Void, Error> = .success(())
    var sessionValid = true

    private(set) var signInCalls = 0
    private(set) var signUpCalls = 0
    private(set) var signOutCalls = 0
    private(set) var lastSignInEmail: String?
    private(set) var lastSignInPassword: String?
    private(set) var lastSignUpEmail: String?
    private(set) var lastSignUpPassword: String?
    private(set) var lastSignUpFullName: String?
    private(set) var lastSignUpPhone: String?

    let authStateChanges = AsyncStream<AuthState>.makeStream().stream

    // Set to hold an in-flight signIn at the repository boundary, so tests
    // can exercise the ViewModel's reentrancy guard deterministically.
    var holdSignIn = false
    private var signInContinuation: CheckedContinuation<User, Error>?

    func signIn(email: String, password: String) async throws -> User {
        signInCalls += 1
        lastSignInEmail = email
        lastSignInPassword = password
        if holdSignIn {
            return try await withCheckedThrowingContinuation { continuation in
                signInContinuation = continuation
            }
        }
        return try signInResult.get()
    }

    func resumeSignIn(_ result: Result<User, Error>) {
        signInContinuation?.resume(with: result)
        signInContinuation = nil
    }

    func signUp(
        email: String,
        password: String,
        fullName: String,
        phone: String
    ) async throws -> User {
        signUpCalls += 1
        lastSignUpEmail = email
        lastSignUpPassword = password
        lastSignUpFullName = fullName
        lastSignUpPhone = phone
        return try signUpResult.get()
    }

    func signOut() async throws {
        signOutCalls += 1
        try signOutResult.get()
    }

    func validateSession() async -> Bool {
        sessionValid
    }
}
