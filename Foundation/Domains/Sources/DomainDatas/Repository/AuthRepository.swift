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

    private let authStateContinuation: AsyncStream<AuthState>.Continuation

    public let authState: AsyncStream<AuthState>

    public init(client: SupabaseClient) {
        self.client = client

        let stream = AsyncStream<AuthState>.makeStream()

        self.authState = stream.stream
        self.authStateContinuation = stream.continuation

        observeAuthState()
    }

    public func signIn(email: String, password: String) async throws
        -> Domains.User
    {
        do {
            let session = try await client.auth.signIn(
                email: email,
                password: password
            )

            return map(session.user)
        } catch {
            throw mapError(error)
        }
    }

    public func signUp(
        email: String,
        password: String,
        fullName: String,
        phone: String
    ) async throws
        -> Domains.User
    {
        do {
            let response = try await client.auth.signUp(
                email: email,
                password: password,
                data: [
                    "full_name": .string(fullName),
                    "phone_number": .string(phone),
                ]
            )

            return map(response.user)
        } catch {
            throw mapError(error)
        }
    }

    public func signOut() async throws {
        try await client.auth.signOut()
    }

    private func observeAuthState() {

        Task { [weak self] in

            guard let self else { return }

            for await (event, session) in client.auth.authStateChanges {

                switch event {

                case .initialSession:

                    guard let session else {
                        authStateContinuation.yield(.unauthenticated)
                        continue
                    }

                    guard !session.isExpired else {
                        authStateContinuation.yield(.unauthenticated)
                        continue
                    }

                    authStateContinuation.yield(
                        .authenticated(map(session.user))
                    )

                case .signedIn:

                    guard let user = session?.user else {
                        authStateContinuation.yield(.unauthenticated)
                        continue
                    }

                    authStateContinuation.yield(
                        .authenticated(map(user))
                    )

                case .signedOut:

                    authStateContinuation.yield(.unauthenticated)

                default:
                    break
                }
            }
        }
    }

    public func validateSession() async -> Bool {
        do {
            let session = try await client.auth.session

            guard !session.isExpired else {
                return false
            }

            _ = try await client.auth.user()

            return !session.isExpired
        } catch {
            return false
        }
    }

    private func mapError(_ error: Error) -> Domains.AuthError {

        if let authError = error as? Supabase.AuthError {

            switch authError.errorCode {

            case .emailExists,
                .userAlreadyExists:
                return .emailAlreadyRegistered

            case .invalidCredentials:
                return .invalidCredentials

            case .emailNotConfirmed:
                return .emailNotConfirmed

            case .weakPassword:
                return .weakPassword

            case .overRequestRateLimit,
                .overEmailSendRateLimit:
                return .rateLimited

            case .signupDisabled:
                return .signUpDisabled

            default:
                return .unknown
            }
        }

        if let urlError = error as? URLError {

            switch urlError.code {

            case .notConnectedToInternet,
                .networkConnectionLost,
                .timedOut:
                return .network

            default:
                return .network
            }
        }

        return .unknown
    }
    private func map(_ user: Supabase.User) -> Domains.User {
        Domains.User(id: user.id.uuidString, email: user.email ?? "")
    }
}
