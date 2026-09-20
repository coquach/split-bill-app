//
//  IAuthRepository.swift
//  Domains
//
//  Created by Co Quach on 18/9/26.
//
public enum AuthError: Error, Sendable, Equatable {
    case invalidCredentials
    case emailNotConfirmed
    case emailAlreadyRegistered
    case weakPassword
    case rateLimited
    case network
    case signUpDisabled
    case unknown
}

public enum AuthState: Sendable {
    case authenticated(User)
    case unauthenticated
}

public protocol IAuthRepository: Sendable {
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String) async throws -> User
    func signOut() async throws
    var authStateChanges: AsyncStream<AuthState> { get }
}
