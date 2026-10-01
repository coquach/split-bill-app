//
//  RepaymentPinView.swift
//  SplitBill
//
//  Created by Dinh Long on 29/9/26.
//

import Domains
import SwiftUI
import SystemDesign

public struct RepaymentPinView: View {
    @State private var viewModel: RepaymentPinViewModel
    private let onBack: () -> Void
    private let onSuccess: (QRRepaymentReceipt) -> Void

    public init(
        viewModel: RepaymentPinViewModel,
        onBack: @escaping () -> Void,
        onSuccess: @escaping (QRRepaymentReceipt) -> Void
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
                Text("Enter your 6-digit PIN to authorize this payment")
                    .font(AppTypography.caption)
                    .foregroundStyle(Color.appSecondary)
                    .multilineTextAlignment(.center)
            }

            OTPCodeInput(
                length: 6,
                code: $viewModel.pin,
                accessibilityID: UITestID.repayPinInput
            )
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
                    isLoading: viewModel.state == .submitting
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
        .screenLifecycle("RepaymentPin")
        .modalOverlay(isPresented: viewModel.errorMessage != nil) {
            AppModal(
                icon: Image(systemName: "exclamationmark.triangle.fill"),
                title: "Payment Failed",
                message: viewModel.errorMessage ?? "Something went wrong.",
                accessibilityID: UITestID.errorModalTitle
            ) {
                AppButton(title: "Try Again", style: .primary, accessibilityID: UITestID.errorModalRetry) {
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
}
