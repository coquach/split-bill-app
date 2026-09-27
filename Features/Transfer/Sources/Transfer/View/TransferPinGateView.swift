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
            topNavBar

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

            OTPCodeInput(length: 4, code: $viewModel.pin)
                .frame(maxWidth: 300)
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
        .background(Color.appBackground)
        .navigationBarHidden(true)
        .screenLifecycle("TransferPinGate")
    }

    private var topNavBar: some View {
        HStack {
            Button(action: onCancel) {
                Image(systemName: "chevron.left")
                    .foregroundStyle(Color.appOnSurface)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Transfer")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.appOnSurface)

            Spacer()

            Color.clear.frame(width: 44, height: 44)
        }
        .frame(height: 44)
    }
}
