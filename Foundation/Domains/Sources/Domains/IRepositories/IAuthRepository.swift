//
//  IAuthRepository.swift
//  Domains
//
//  Created by Co Quach on 18/9/26.
//

public enum AuthState: Sendable {
    case authenticated(User)
    case unauthenticated
}

public protocol IAuthRepository: Sendable {
    func signIn(email: String, password: String) async throws -> User
    func signUp(
        email: String,
        password: String,
        fullName: String,
        phone: String
    ) async throws -> User
    func signOut() async throws
    func validateSession() async -> Bool
    var authState: AsyncStream<AuthState> { get }
}
