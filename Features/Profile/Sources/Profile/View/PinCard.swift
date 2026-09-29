//
//  PinCard.swift
//  Profile
//
//  Created by Co Quach on 29/9/26.
//

import SwiftUI
import SystemDesign

struct PinCard: View {

    let hasPin: Bool
    let action: () -> Void

    private var title: String {
        hasPin
            ? "Change your transaction PIN"
            : "Set up your transaction PIN"
    }

    private var subtitle: String {
        hasPin
            ? "Update your 6-digit PIN to keep your account secure."
            : "Protect transfers and repayments with a 6-digit PIN."
    }

    private var icon: String {
        hasPin ? "key.fill" : "lock.fill"
    }

    private var iconColor: Color {
        hasPin
            ? Color.appPrimary
            : Color.appWarning
    }

    private var iconBackground: Color {
        hasPin
            ? Color.appPrimary.opacity(0.12)
            : Color.appWarningBackground
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {

                ZStack {
                    Circle()
                        .fill(iconBackground)

                    Image(systemName: icon)
                        .font(
                            .system(
                                size: 18,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(iconColor)
                }
                .frame(width: 48, height: 48)

                VStack(
                    alignment: .leading,
                    spacing: AppSpacing.xxs
                ) {
                    Text(title)
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(Color.appTextPrimary)

                    Text(subtitle)
                        .font(AppTypography.caption)
                        .foregroundStyle(Color.appTextSecondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(
                        .system(
                            size: 14,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(Color.appTextTertiary)
            }
            .padding(AppSpacing.lg)
            .background(
                hasPin
                ? Color.appSubtle
                    : Color.appWarningBackground
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppRadius.xl,
                    style: .continuous
                )
            )
        }
        .buttonStyle(.plain)
    }
}
