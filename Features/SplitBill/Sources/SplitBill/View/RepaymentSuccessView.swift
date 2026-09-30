//
//  RepaymentSuccessView.swift
//  SplitBill
//
//  Created by Dinh Long on 29/9/26.
//

import Domains
import SwiftUI
import SystemDesign

public struct RepaymentSuccessView: View {
    private let receipt: QRRepaymentReceipt
    private let onDone: () -> Void

    public init(receipt: QRRepaymentReceipt, onDone: @escaping () -> Void) {
        self.receipt = receipt
        self.onDone = onDone
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
                Text("Payment Successful")
                    .font(AppTypography.title)
                    .foregroundStyle(.white)
                Text("\(receipt.amount.formatted) VND paid")
                    .font(AppTypography.body)
                    .foregroundStyle(.white.opacity(0.8))
            }

            Spacer()
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
        .safeAreaInset(edge: .bottom, spacing: 0) {
            BottomActionBar(
                primary: .init(title: "Done", style: .primary, handler: onDone),
                background: .clear
            )
        }
        .navigationBarBackButtonHidden(true)
        .screenLifecycle("RepaymentSuccess")
    }
}
