import Domains
import SwiftUI
import SystemDesign

public struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    @State private var isShowingPinSetup = false
    @State private var isShowingChangePin = false

    public init(viewModel: ProfileViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                profileCard

                PinCard(
                    hasPin: viewModel.hasPin
                ) {
                    if viewModel.hasPin {
                        isShowingChangePin = true
                    } else {
                        isShowingPinSetup = true
                    }
                }

                logoutButton
            }
            .padding(.horizontal, AppSpacing.xl)
            .padding(.top, AppSpacing.md)
            .padding(.bottom, AppSpacing.xxxl)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .task {
            await viewModel.load()
        }
        .refreshable {
            await viewModel.load()
        }
        .sheet(isPresented: $isShowingPinSetup) {
            NavigationStack {
                PinSetupView { pin in
                    await viewModel.setupPin(pin)
                }
            }
        }
        .sheet(isPresented: $isShowingChangePin) {
            NavigationStack {
                ChangePinView { currentPin, newPin in
                    await viewModel.changePin(
                        currentPin: currentPin,
                        newPin: newPin
                    )
                }
            }
        }
        .alert(
            "Something went wrong",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.clearError() } }
            )
        ) {
            Button("OK", role: .cancel) {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }



    private var profileCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            HStack(spacing: AppSpacing.md) {
                ZStack {
                    Circle()
                        .fill(Color.appSubtle)

                    Image(systemName: "person.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(Color.appPrimary)
                }
                .frame(width: 56, height: 56)

                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text(viewModel.displayName)
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(Color.appTextPrimary)

                    Text(viewModel.statusText)
                        .font(AppTypography.caption)
                        .foregroundStyle(Color.appSuccess)
                }

                Spacer()
            }

            Divider()

            ProfileInfoRow(
                icon: "envelope.fill",
                title: "Email",
                value: viewModel.email
            )

            ProfileInfoRow(
                icon: "phone.fill",
                title: "Phone",
                value: viewModel.phoneNumber
            )
        }
        .padding(AppSpacing.lg)
        .background(Color.appSurfacePrimary)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppRadius.xl,
                style: .continuous
            )
        )
    }


    private var logoutButton: some View {
        Button {
            Task {
                await viewModel.signOut()
            }
        } label: {
            HStack {
                if viewModel.isSigningOut {
                    ProgressView()
                        .tint(Color.appError)
                } else {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                }

                Text("Log out")
            }
            .font(AppTypography.bodyMedium)
            .foregroundStyle(Color.appSurfacePrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.appError)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppRadius.lg,
                    style: .continuous
                )
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: AppRadius.lg,
                    style: .continuous
                )
                .stroke(Color.appError.opacity(0.25), lineWidth: 1)
            }
        }
        .disabled(viewModel.isSigningOut)
    }
}


