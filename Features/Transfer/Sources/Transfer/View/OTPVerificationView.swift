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
    private let onSuccess: (TransferReceipt) -> Void

    public init(viewModel: OTPVerificationViewModel, onSuccess: @escaping (TransferReceipt) -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onSuccess = onSuccess
    }

    public var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()

            VStack(spacing: AppSpacing.xs) {
                Text("Enter your transaction PIN")
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(Color.appOnSurface)
                Text("Confirm it's you before this transfer goes through")
                    .font(AppTypography.caption)
                    .foregroundStyle(Color.appOnSurface.opacity(0.6))
                    .multilineTextAlignment(.center)
            }

            OTPCodeInput(code: $viewModel.pin)

            Spacer()

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
        }
        .padding(AppSpacing.lg)
        .background(Color.appBackground)
        .navigationTitle("Verification")
        .navigationBarTitleDisplayMode(.inline)
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

    private var isShowingError: Bool {
        if case .failed = viewModel.state { return true }
        return false
    }
}
