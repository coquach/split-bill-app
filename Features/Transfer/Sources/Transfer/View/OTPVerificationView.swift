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
        VStack(spacing: 0) {
            topNavBar

            Spacer(minLength: AppSpacing.lg)

            iconBadge

            Spacer(minLength: AppSpacing.lg)

            VStack(spacing: AppSpacing.xs) {
                Text("Enter PIN")
                    .font(AppTypography.title)
                    .foregroundStyle(Color.appOnSurface)
                Text("Enter your 4-digit PIN to authorize this transfer")
                    .font(AppTypography.caption)
                    .foregroundStyle(Color.appSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, AppSpacing.xxl)
            }

            Spacer(minLength: AppSpacing.xl)

            OTPCodeInput(length: 4, code: $viewModel.pin, isKeyboardDriven: false)
                .frame(maxWidth: 300)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, AppSpacing.lg)

            Spacer(minLength: AppSpacing.xl)

            AppButton(
                title: "Verify",
                style: .primary,
                isLoading: viewModel.state == .verifying
            ) {
                Task {
                    await viewModel.submit()
                    if let receipt = viewModel.receipt {
                        onSuccess(receipt)
                    }
                }
            }
            .disabled(!viewModel.isPinComplete || viewModel.state == .verifying)
            .opacity(viewModel.isPinComplete ? 1 : 0.35)
            .padding(.horizontal, AppSpacing.lg)

            Spacer(minLength: AppSpacing.lg)

            NumericKeypadTray(
                onDigit: viewModel.appendDigit,
                onBackspace: viewModel.deleteLast
            )
        }
        .background(Color.appBackground)
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

    private var topNavBar: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .foregroundStyle(Color.appOnSurface)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Verify")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.appOnSurface)

            Spacer()

            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, AppSpacing.xs)
        .frame(height: 44)
        .background(Color.appBackground)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.black.opacity(0.05))
                .frame(height: 1)
                .blur(radius: 2)
                .offset(y: 2)
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
