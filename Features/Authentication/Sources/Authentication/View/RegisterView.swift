import CommonUi
//
//  RegisterView.swift
//  Authentication
//
//  Created by Co Quach on 18/9/26.
//
import SwiftUI
import SystemDesign

struct RegisterView: View {

    @State
    private var viewModel: RegisterViewModel

    private let onNavigateToLogin: () -> Void

    public init(
        viewModel: RegisterViewModel,
        onNavigateToLogin: @escaping () -> Void
    ) {
        self._viewModel = State(
            initialValue: viewModel
        )
        self.onNavigateToLogin = onNavigateToLogin
    }

    var body: some View {
        ZStack {
            AuthBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    AuthHeader(
                        icon: "person.badge.plus",
                        title: "Create your account",
                        subtitle:
                            "Join friends and start splitting bills effortlessly",
                        iconSize: 20
                    )

                    form
                        .padding(.top, 28)

                    footer
                        .padding(.top, 24)
                        .padding(.bottom, 24)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.top, 8)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
        }
        .alert(
            "Unable to create account",
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
        .alert(
            "Check your email",
            isPresented: Binding(
                get: {
                    if case .success = viewModel.state {
                        return true
                    }
                    return false
                },
                set: { isPresented in
                    if !isPresented {
                        viewModel.dismissEmailConfirmation()
                    }
                }
            )
        ) {
            Button("OK") {
                viewModel.dismissEmailConfirmation()
            }
        } message: {
            Text(
                "We've sent a confirmation link to \(viewModel.email). " +
                "Please verify your email before signing in."
            )
        }
    }
    private var form: some View {

        VStack(spacing: 16) {

            AppTextField(
                title: "Full name",
                placeholder: "Your full name",
                text: $viewModel.fullName,
                errorMessage: viewModel.fullNameError
            )
            AppTextField(
                title: "Phone number",
                placeholder: "0123456789",
                text: $viewModel.phone,
                errorMessage: viewModel.phoneError
            ).textInputAutocapitalization(.never)
                .keyboardType(.namePhonePad)
                .autocorrectionDisabled()

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
            AppSecureField(
                title: "Confirm Password",
                placeholder: "••••••••••••",
                text: $viewModel.confirmPassword,
                errorMessage: viewModel.confirmPasswordError
            )

            AppButton(
                title: "Sign Up",
                isLoading: viewModel.state == .submitting
            ) {
                Task {
                    await viewModel.signUp()
                }
            }
        }
    }

    private var footer: some View {

        VStack(spacing: 16) {
            Rectangle()
                .fill(Color.appBorderDefault)
                .frame(height: 1)

            HStack(spacing: 4) {
                Text("Already have an account?")
                    .foregroundStyle(Color.appTextSecondary)

                Button("Sign In") {
                    onNavigateToLogin()
                }
                .fontWeight(.bold)
                .foregroundStyle(Color.appPrimary)
            }
            .font(.system(size: 14))
        }
    }
}
