//
//  TransferPinGateView.swift
//  Transfer
//
//  Created by Dinh Long on 27/9/26.
//

import SwiftUI
import SystemDesign

public struct TransferPinGateView: View {
    @State private var viewModel: PinGateViewModel
    private let onVerified: () -> Void
    private let onCancel: () -> Void

    public init(
        viewModel: PinGateViewModel,
        onVerified: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onVerified = onVerified
        self.onCancel = onCancel
    }

    public var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()

            VStack(spacing: AppSpacing.xs) {
                Text("Enter your PIN")
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(Color.appOnSurface)
                Text("Enter your PIN to continue to Transfer")
                    .font(AppTypography.caption)
                    .foregroundStyle(Color.appSecondary)
                    .multilineTextAlignment(.center)
            }

            OTPCodeInput(length: TransferPIN.length, code: $viewModel.pin)
                .frame(maxWidth: 340)
                .frame(maxWidth: .infinity)

            if viewModel.isIncorrect {
                AlertBanner(message: "Incorrect PIN. Please try again.", style: .error)
            }

            Spacer()

            AppButton(title: "Continue", style: .primary) {
                if viewModel.verify() {
                    onVerified()
                }
            }
            .disabled(!viewModel.isPinComplete)
            .opacity(viewModel.isPinComplete ? 1 : 0.35)
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground.ignoresSafeArea())
        .safeAreaInset(edge: .top, spacing: 0) {
            AppNavBar(title: "Transfer", onBack: onCancel)
        }
        .navigationBarHidden(true)
        .screenLifecycle("TransferPinGate")
    }
}
