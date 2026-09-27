//
//  TransferSuccessView.swift
//  Transfer
//
//  Created by Dinh Long on 26/9/26.
//

import Domains
import SwiftUI
import SystemDesign

public struct TransferSuccessView: View {
    private let receipt: TransferReceipt
    private let onViewDetails: () -> Void
    private let onBackToHome: () -> Void

    public init(
        receipt: TransferReceipt,
        onViewDetails: @escaping () -> Void,
        onBackToHome: @escaping () -> Void
    ) {
        self.receipt = receipt
        self.onViewDetails = onViewDetails
        self.onBackToHome = onBackToHome
    }

    public var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 96, height: 96)
                Image(systemName: "checkmark")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(Color.appPrimary)
            }

            VStack(spacing: AppSpacing.xs) {
                Text("Transfer Successful")
                    .font(AppTypography.title)
                    .foregroundStyle(.white)
                Text("Your money is on its way")
                    .font(AppTypography.body)
                    .foregroundStyle(.white.opacity(0.8))
            }

            Spacer()

            VStack(spacing: AppSpacing.sm) {
                AppButton(title: "View Details", style: .secondary, action: onViewDetails)
                AppButton(title: "Back to Home", style: .translucent, action: onBackToHome)
            }
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [Color.appPrimary, Color.appPrimaryContainer],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)
        .screenLifecycle("TransferSuccess")
    }
}
