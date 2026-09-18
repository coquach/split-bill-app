//
//  HomeViewModel.swift
//  Home
//
//  Created by Co Quach on 18/9/26.
//
import Observation
import Domains

@MainActor
@Observable
public final class HomeViewModel {

    // MARK: - UI State

    private(set) var email: String
    private(set) var isLoggingOut = false
    private(set) var errorMessage: String?

    // MARK: - Dependencies

    private let authRepository: IAuthRepository

    // MARK: - Init

    public init(
        user: User,
        authRepository: IAuthRepository
    ) {
        self.email = user.email
        self.authRepository = authRepository
    }

    // MARK: - Actions
    func logout() async {
        guard !isLoggingOut else {
            return
        }

        isLoggingOut = true
        errorMessage = nil

        defer {
            isLoggingOut = false
        }

        do {
            try await authRepository.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
