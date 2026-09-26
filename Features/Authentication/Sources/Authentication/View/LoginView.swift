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

    public init(
        viewModel: LoginViewModel,
        onNavigateToRegister: @escaping () -> Void
    ) {
        self._viewModel = State(
            initialValue: viewModel
        )
        self.onNavigateToRegister = onNavigateToRegister
    }

    var body: some View {
        ZStack {
            AuthBackground()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                AuthHeader(
                    icon: "arrow.left.arrow.right",
                    title: "Welcome back",
                    subtitle:
                        "Sign in to continue splitting and managing bills"
                )

                form
                    .padding(.top, 32)

                Spacer(minLength: 24)

                footer
                    .padding(.top, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .alert(
            "Unable to sign in",
            isPresented: Binding(
                get: {
                    if case .failure = viewModel.state {
                        return true
                    }

                    return false
                },
                set: { newValue in
                    if !newValue {
                        viewModel.dismissError()
                    }
                }
            )
        ) {
            Button("OK") {
                viewModel.dismissError()
            }
        } message: {
            if case .failure(let error) = viewModel.state {
                Text(error.message)
            }
        }
    }

    private var form: some View {

        VStack(spacing: 16) {

            AppTextField(
                title: "Email",
                placeholder: "name@example.com",
                text: $viewModel.email,
                errorMessage: viewModel.emailError
            ).textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()

            AppSecureField(
                title: "Password",
                placeholder: "••••••••••••",
                text: $viewModel.password,
                errorMessage: viewModel.passwordError
            )

            AppButton(
                title: "Sign in",
                isLoading: viewModel.state == .submitting
            ) {
                Task {
                    await viewModel.signIn()
                }
            }

        }
    }

    private var footer: some View {

        VStack(spacing: 24) {
            Rectangle()
                .fill(Color.appBorderDefault)
                .frame(height: 1)

            HStack(spacing: 4) {
                Text("Don't have an account?")
                    .foregroundStyle(Color.appTextSecondary)

                Button("Sign Up") {
                    onNavigateToRegister()
                }
                .fontWeight(.bold)
                .foregroundStyle(Color.appPrimary)
            }
            .font(.system(size: 14))
        }
    }
}
