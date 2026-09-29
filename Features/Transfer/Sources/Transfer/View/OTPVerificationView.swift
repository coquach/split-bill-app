//
//  OTPVerificationView.swift
//  Transfer
//
//  Created by Dinh Long on 26/9/26.
//

import Domains
import SwiftUI
import SystemDesign

public struct OTPVerificationView: View {
    @State private var viewModel: OTPVerificationViewModel
    private let onBack: () -> Void
    private let onSuccess: (TransferReceipt) -> Void

    public init(
        viewModel: OTPVerificationViewModel,
        onBack: @escaping () -> Void,
        onSuccess: @escaping (TransferReceipt) -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onBack = onBack
        self.onSuccess = onSuccess
    }

    public var body: some View {
        VStack(spacing: AppSpacing.xl) {
            iconBadge

            VStack(spacing: AppSpacing.xs) {
                Text("Enter PIN")
                    .font(AppTypography.title)
                    .foregroundStyle(Color.appOnSurface)
                Text("Enter your 6-digit PIN to authorize this transfer")
                    .font(AppTypography.caption)
                    .foregroundStyle(Color.appSecondary)
                    .multilineTextAlignment(.center)
            }

            OTPCodeInput(length: TransferPIN.length, code: $viewModel.pin)
                .frame(maxWidth: 340)
                .frame(maxWidth: .infinity)

            Spacer()
        }
        .padding(AppSpacing.lg)
        .padding(.top, AppSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.appBackground.ignoresSafeArea())
        .safeAreaInset(edge: .top, spacing: 0) {
            AppNavBar(title: "Verify", onBack: onBack)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            BottomActionBar(
                primary: .init(
                    title: "Verify",
                    style: .primary,
                    isEnabled: viewModel.isPinComplete,
                    isLoading: viewModel.state == .verifying
                ) {
                    Task {
                        await viewModel.submit()
                        if let receipt = viewModel.receipt {
                            onSuccess(receipt)
                        }
                    }
                }
            )
        }
        .navigationBarHidden(true)
        .screenLifecycle("OTPVerification")
        .modalOverlay(isPresented: isShowingError) {
            AppModal(
                icon: Image(systemName: "exclamationmark.triangle.fill"),
                title: "Transfer Failed",
                message: viewModel.errorMessage ?? "Something went wrong."
            ) {
                AppButton(title: "Try Again", style: .primary) {
                    viewModel.retry()
                }
            }
        }
    }

    private var iconBadge: some View {
        Circle()
            .fill(Color.appIconBadge)
            .frame(width: 72, height: 72)
            .overlay {
                Image(systemName: "shield.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.appOnSurface)
            }
    }

    private var isShowingError: Bool {
        if case .failed = viewModel.state { return true }
        return false
    }
}
