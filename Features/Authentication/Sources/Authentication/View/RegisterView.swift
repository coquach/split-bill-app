import CommonUi
//
//  RegisterView.swift
//  Authentication
//
//  Created by Co Quach on 18/9/26.
//
import SwiftUI
import SystemDesign

public struct RegisterView: View {

    @State
    private var viewModel: RegisterViewModel

    private let onNavigateToLogin: () -> Void

    @State
    private var alert: AppAlert?

    @State
    private var showSuccessSheet = false

    public init(
        viewModel: RegisterViewModel,
        onNavigateToLogin: @escaping () -> Void
    ) {
        self._viewModel = State(
            initialValue: viewModel
        )
        self.onNavigateToLogin = onNavigateToLogin
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
        .scrollDismissesKeyboard(.interactively)
        .background(Color.appBackground)
        .appAlert(item: $alert)
        .onChange(of: viewModel.state) { _, newState in
            handleStateChange(newState)
        }
        .sheet(isPresented: $showSuccessSheet) {
            RegisterSuccessSheet(
                email: viewModel.email
            )
        }
    }
}

// MARK: - Header

extension RegisterView {

    fileprivate var header: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.sm
        ) {
            Text("Create your account")
                .font(AppTypography.display)
                .foregroundStyle(Color.appOnSurface)

            Text(
                "Start managing your shared expenses with SplitPay."
            )
            .font(AppTypography.body)
            .foregroundStyle(Color.appSecondary)
            .fixedSize(
                horizontal: false,
                vertical: true
            )
        }
    }
}

// MARK: - Form

extension RegisterView {

    fileprivate var form: some View {
        VStack(spacing: AppSpacing.md) {

            AppTextField(
                title: "Email",
                placeholder: "you@example.com",
                text: $viewModel.email,
                errorMessage: emailError
            )

            AppSecureField(
                title: "Password",
                placeholder: "Create a password",
                text: $viewModel.password,
                errorMessage: passwordError

            )

            AppSecureField(
                title: "Confirm password",
                placeholder: "Repeat your password",
                text: $viewModel.confirmPassword,
                errorMessage: confirmPasswordError
            )

            AppButton(
                title: "Create account",
                style: .accent,
                isLoading: isLoading
            ) {
                Task {
                    await viewModel.signUp()
                }
            }
        }
    }

    fileprivate var isLoading: Bool {
        if case .loading = viewModel.state {
            return true
        }

        return false
    }
}

// MARK: - Footer

extension RegisterView {

    fileprivate var footer: some View {
        HStack(spacing: 4) {
            Text("Already have an account?")
                .foregroundStyle(Color.appSecondary)

            Button(
                "Sign in",
                action: onNavigateToLogin
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
}

extension RegisterView {

    fileprivate func handleStateChange(
        _ state: RegisterViewModel.State
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

extension RegisterView {

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

        case .weakPassword:
            return "Password must be at least 8 characters"

        default:
            return nil
        }
    }

    fileprivate var confirmPasswordError: String? {
        guard case .validation(let error) = viewModel.state else {
                return nil
            }

        switch error {
        case .passwordMismatch:
            return "Passwords do not match"

        default:
            return nil
        }
    }
}
