//
//  RepaymentReviewView.swift
//  SplitBill
//
//  Created by Dinh Long on 29/9/26.
//

import Domains
import SwiftUI
import SystemDesign

public struct RepaymentReviewView: View {
    private let scanned: ScannedRepayment
    private let onBack: () -> Void
    private let onContinue: () -> Void

    public init(
        scanned: ScannedRepayment,
        onBack: @escaping () -> Void,
        onContinue: @escaping () -> Void
    ) {
        self.scanned = scanned
        self.onBack = onBack
        self.onContinue = onContinue
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                InfoCard {
                    VStack(spacing: AppSpacing.md) {
                        VStack(spacing: AppSpacing.xxs) {
                            Text("YOU ARE PAYING")
                                .font(AppTypography.label)
                                .foregroundStyle(Color.appOnSurface.opacity(0.5))

                            HStack(alignment: .firstTextBaseline, spacing: AppSpacing.xxs) {
                                Text(money(scanned.review.perPersonAmount))
                                    .font(AppTypography.display)
                                Text(scanned.review.currency)
                                    .font(AppTypography.bodyMedium)
                                    .foregroundStyle(Color.appOnSurface.opacity(0.6))
                            }
                        }
                        .frame(maxWidth: .infinity)

                        Divider()

                        DividedInfoStack([
                            .init(label: "Split", value: scanned.review.title),
                            .init(
                                label: "Requested by",
                                value: scanned.review.requesterName ?? "Unknown"
                            ),
                            .init(
                                label: "Remaining slots",
                                value: "\(scanned.review.remainingSlots)"
                            ),
                        ])
                    }
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.lg)
            .padding(.bottom, AppSpacing.xxl)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .safeAreaInset(edge: .top, spacing: 0) {
            AppNavBar(title: "Pay Split", onBack: onBack)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            BottomActionBar(
                primary: .init(title: "Confirm & Pay", style: .primary, accessibilityID: UITestID.repayReviewConfirm, handler: onContinue),
                secondary: .init(title: "Cancel", style: .secondary, handler: onBack)
            )
        }
        .navigationBarHidden(true)
        .screenLifecycle("RepaymentReview")
    }

    private func money(_ amount: Int64) -> String {
        Amount(Double(amount)).formatted
    }
}
