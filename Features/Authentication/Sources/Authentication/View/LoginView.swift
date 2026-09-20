import CommonUi
//
//  LoginView.swift
//  Authentication
//
//  Created by Co Quach on 18/9/26.
//
import SwiftUI
import SystemDesign

struct LoginView: View {

    @State
    private var viewModel: LoginViewModel

    private let onNavigateToRegister: () -> Void

    @State
    private var showingAlert = false

    @State
    private var alert: AppAlert?

    public init(
        viewModel: LoginViewModel,
        onNavigateToRegister: @escaping () -> Void
    ) {
        self._viewModel = State(
            initialValue: viewModel
        )
        self.onNavigateToRegister = onNavigateToRegister
    }

    public var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: AppSpacing.lg
            ) {
                header

                form

                footer
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.xxl)
        }

        .background(Color.appBackground)
        .scrollDismissesKeyboard(.interactively)
        .appAlert(item: $alert)
        .onChange(of: viewModel.state) { _, newState in
            handleStateChange(newState)
        }
    }

    private var header: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.sm
        ) {
            Text("Welcome back")
                .font(AppTypography.display)
                .foregroundStyle(Color.appOnSurface)

            Text("Sign in to continue managing your expenses.")
                .font(AppTypography.body)
                .foregroundStyle(Color.appSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var form: some View {
        VStack(spacing: AppSpacing.md) {

            AppTextField(
                title: "Email",
                placeholder: "you@example.com",
                text: $viewModel.email,
                errorMessage: emailError
            )

            AppSecureField(
                title: "Password",
                placeholder: "Enter your password",
                text: $viewModel.password,
                errorMessage: passwordError
            )

            AppButton(
                title: "Sign in",
                style: .accent,
                isLoading: isLoading
            ) {
                Task {
                    await viewModel.signIn()
                }
            }
        }
    }

    private var footer: some View {
        HStack(spacing: 4) {
            Text("Don't have an account?")
                .foregroundStyle(Color.appSecondary)

            Button(
                "Create account",
                action: onNavigateToRegister
            )
            .font(AppTypography.label)
            .foregroundStyle(Color.appPrimary)
        }
        .font(AppTypography.caption)
        .frame(
            maxWidth: .infinity,
            alignment: .center
        )
    }

    private var isLoading: Bool {
        if case .loading = viewModel.state {
            return true
        }

        return false
    }
}

extension LoginView {

    fileprivate func handleStateChange(
        _ state: LoginViewModel.State
    ) {
        guard case .auth(let error) = state else {
                return
            }

            switch error {
            case .emailAlreadyRegistered:
                alert = AppAlert(
                    title: "Email already registered",
                    message: "An account with this email already exists."
                )

            case .network:
                alert = AppAlert(
                    title: "Connection error",
                    message: "Please check your connection and try again."
                )

            default:
                alert = AppAlert(
                    title: "Something went wrong",
                    message: "Please try again later."
                )
            }
    }
}

extension LoginView {

    fileprivate var emailError: String? {
        guard case .validation(let error) = viewModel.state else {
                return nil
            }

        switch error {
        case .emptyEmail:
            return "Email is required"

        case .invalidEmail:
            return "Please enter a valid email address"

        default:
            return nil
        }
    }

    fileprivate var passwordError: String? {
        guard case .validation(let error) = viewModel.state else {
                return nil
            }

        switch error {
        case .emptyPassword:
            return "Password is required"

        default:
            return nil
        }
    }
}
