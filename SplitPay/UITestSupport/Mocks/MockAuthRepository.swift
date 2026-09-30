//
//  MockAuthRepository.swift
//  SplitPay
//

#if DEBUG
    import Domains
    import Foundation

    /// Signs in instantly for any credentials except the magic failing email.
    /// The `authStateChanges` stream stays open for the process lifetime — the
    /// app's coordinator iterates it forever.
    @MainActor
    final class MockAuthRepository: IAuthRepository {
        let authStateChanges: AsyncStream<AuthState>

        private let store: MockAppStore
        private var continuation: AsyncStream<AuthState>.Continuation
        private let sessionIsValid: Bool

        init(store: MockAppStore, authenticated: Bool, sessionIsValid: Bool) {
            self.store = store
            self.sessionIsValid = sessionIsValid

            var continuation: AsyncStream<AuthState>.Continuation!
            authStateChanges = AsyncStream { continuation = $0 }
            self.continuation = continuation

            // AsyncStream buffers values produced before iteration begins, so
            // emitting the initial state here is safe — the coordinator picks it
            // up the moment `start()` begins iterating.
            continuation.yield(authenticated ? .authenticated(store.user) : .unauthenticated)
        }

        func signIn(email: String, password _: String) async throws -> User {
            guard email != UITestSeedData.failingEmail else {
                throw AuthError.invalidCredentials
            }
            let user = User(id: store.user.id, email: email)
            continuation.yield(.authenticated(user))
            return user
        }

        func signUp(
            email: String,
            password _: String,
            fullName _: String,
            phone _: String
        ) async throws -> User {
            guard email != UITestSeedData.failingEmail else {
                throw AuthError.emailAlreadyRegistered
            }
            let user = User(id: store.user.id, email: email)
            continuation.yield(.authenticated(user))
            return user
        }

        func signOut() async throws {
            continuation.yield(.unauthenticated)
        }

        func validateSession() async -> Bool {
            sessionIsValid
        }
    }
#endif
