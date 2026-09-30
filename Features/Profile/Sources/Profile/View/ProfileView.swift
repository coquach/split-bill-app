import Domains
import SwiftUI
import SystemDesign

public struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    @State private var isShowingPinSetup = false
    @State private var isShowingChangePin = false
    @State private var isShowingLogoutConfirmation = false

    public init(viewModel: ProfileViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                profileHeader

                contactCard

                settingsCard

                logoutButton
            }
            .padding(.horizontal, AppSpacing.xl)
            .padding(.top, AppSpacing.md)
            .padding(.bottom, AppSpacing.xl)
        }
        .background(Color.appBackground.ignoresSafeArea())
        // Root tab screen: the title above replaces the system navigation bar
        .toolbar(.hidden, for: .navigationBar)
        .modalOverlay(isPresented: isShowingLogoutConfirmation) {
            AppModal(
                icon: Image(systemName: "rectangle.portrait.and.arrow.right"),
                title: "Log Out?",
                message: "Are you sure you want to log out?"
            ) {
                // Back closes the modal and stays signed in; Confirm closes it and signs out
                HStack(spacing: AppSpacing.sm) {
                    AppButton(title: "Back", style: .secondary) {
                        isShowingLogoutConfirmation = false
                    }

                    AppButton(title: "Confirm", style: .destructive) {
                        isShowingLogoutConfirmation = false
                        Task {
                            await viewModel.signOut()
                        }
                    }
                }
            }
        }
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
                ChangePinView(
                    onVerifyCurrent: { currentPin in
                        await viewModel.verifyPin(currentPin)
                    },
                    onSubmit: { currentPin, newPin in
                        await viewModel.changePin(
                            currentPin: currentPin,
                            newPin: newPin
                        )
                    }
                )
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

    // Centered on the page background, not boxed in a card
    private var profileHeader: some View {
        VStack(spacing: AppSpacing.xxs) {
            Avatar(
                name: viewModel.profile?.fullName ?? viewModel.displayName,
                size: .xlarge
            )
            .padding(.bottom, AppSpacing.sm)

            Text(viewModel.displayName)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, AppSpacing.sm)
    }

    // Email and phone as a small table: label on the left, value on the right
    private var contactCard: some View {
        InfoCard {
            DividedInfoStack([
                .init(label: "Email", value: viewModel.email),
                .init(label: "Phone", value: viewModel.phoneNumber),
            ])
        }
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 3)
    }

    // One row today; more SettingsRow entries can be stacked inside later
    private var settingsCard: some View {
        InfoCard {
            SettingsRow(
                icon: viewModel.hasPin ? "key.fill" : "lock.fill",
                title: viewModel.hasPin
                    ? "Change Transaction PIN"
                    : "Set Up Transaction PIN"
            ) {
                if viewModel.hasPin {
                    isShowingChangePin = true
                } else {
                    isShowingPinSetup = true
                }
            }
        }
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 3)
    }

    private var logoutButton: some View {
        AppButton(
            title: "Log Out",
            style: .destructiveSecondary,
            icon: "rectangle.portrait.and.arrow.right",
            isLoading: viewModel.isSigningOut
        ) {
            isShowingLogoutConfirmation = true
        }
    }
}
