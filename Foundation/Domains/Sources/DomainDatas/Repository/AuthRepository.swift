//
//  AuthRepository.swift
//  Domains
//
//  Created by Co Quach on 18/9/26.
//

import Domains
import Foundation
import Supabase

public final class AuthRepository: IAuthRepository {

    // MARK: - Dependencies

    private let client: SupabaseClient

    // MARK: - Auth State

    private let authStateContinuation: AsyncStream<AuthState>.Continuation

    public let authStateChanges: AsyncStream<AuthState>

    private var authObservationTask: Task<Void, Never>?

    // MARK: - Init

    public init(client: SupabaseClient) {
        self.client = client

        let stream = AsyncStream<AuthState>.makeStream()

        self.authStateChanges = stream.stream
        self.authStateContinuation = stream.continuation

        startAuthObservation()
    }

    deinit {
        authObservationTask?.cancel()
        authObservationTask = nil

        authStateContinuation.finish()
    }

    // MARK: - Sign In

    public func signIn(
        email: String,
        password: String
    ) async throws -> Domains.User {

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

    // MARK: - Sign Up

    public func signUp(
        email: String,
        password: String,
        fullName: String,
        phone: String
    ) async throws -> Domains.User {

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

    // MARK: - Sign Out

    public func signOut() async throws {

        do {
            try await client.auth.signOut()

        } catch {
            throw mapError(error)
        }
    }

    // MARK: - Auth Observation

    private func startAuthObservation() {

        authObservationTask?.cancel()

        authObservationTask = Task { [weak self] in

            guard let self else {
                return
            }

            for await (event, session)
                in client.auth.authStateChanges
            {
                guard !Task.isCancelled else {
                    break
                }

                switch event {

                case .initialSession:
                    handleInitialSession(session)

                case .signedIn:
                    handleSignedIn(session)

                case .signedOut:
                    authStateContinuation.yield(
                        .unauthenticated
                    )

                default:
                    break
                }
            }
        }
    }

    private func handleInitialSession(
        _ session: Session?
    ) {

        guard let session else {
            authStateContinuation.yield(
                .unauthenticated
            )
            return
        }

        guard !session.isExpired else {
            authStateContinuation.yield(
                .unauthenticated
            )
            return
        }

        authStateContinuation.yield(
            .authenticated(
                map(session.user)
            )
        )
    }

    private func handleSignedIn(
        _ session: Session?
    ) {

        guard let user = session?.user else {
            authStateContinuation.yield(
                .unauthenticated
            )
            return
        }

        authStateContinuation.yield(
            .authenticated(
                map(user)
            )
        )
    }

    // MARK: - Session Validation

    public func validateSession() async -> Bool {

        do {
            let session = try await client.auth.session

            guard !session.isExpired else {
                return false
            }

            _ = try await client.auth.user()

            return true

        } catch {
            return false
        }
    }

    // MARK: - Error Mapping

    private func mapError(
        _ error: Error
    ) -> Domains.AuthError {

        // Unrecognised errors all collapse to .unknown, so log the real one.
        print("[Auth] raw error: \(String(reflecting: error))")

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

    // MARK: - Mapping

    private func map(
        _ user: Supabase.User
    ) -> Domains.User {

        Domains.User(
            id: user.id,
            email: user.email ?? ""
        )
    }
}
