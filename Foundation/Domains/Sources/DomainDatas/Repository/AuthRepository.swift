import Domains
//
//  AuthRepository.swift
//  Domains
//
//  Created by Co Quach on 18/9/26.
//
import Foundation
import Supabase

public final class AuthRepository: IAuthRepository {
    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }

    public func signIn(email: String, password: String) async throws
        -> Domains.User
    {
        let session = try await client.auth.signIn(
            email: email,
            password: password
        )
        return map(session.user)
    }

    public func signUp(email: String, password: String) async throws
        -> Domains.User
    {
        let response = try await client.auth.signUp(
            email: email,
            password: password
        )
        return map(response.user)
    }

    public func signOut() async throws {
        try await client.auth.signOut()
    }

    public var authStateChanges: AsyncStream<AuthState> {
        AsyncStream { continuation in
            let task = Task {
                for await (event, session) in client.auth.authStateChanges {
                    switch event {
                    case .initialSession:
                        guard let session else {
                            continuation.yield(.unauthenticated)
                            continue
                        }

                        if session.isExpired {
                            continuation.yield(.unauthenticated)
                        } else {
                            continuation.yield(
                                .authenticated(map(session.user))
                            )
                        }
                    case .signedIn:
                        if let user = session?.user {
                            continuation.yield(.authenticated(map(user)))
                        }
                    case .signedOut:
                        continuation.yield(.unauthenticated)
                    default:
                        break
                    }
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    private func map(_ user: Supabase.User) -> Domains.User {
        Domains.User(id: user.id.uuidString, email: user.email ?? "")
    }
}
