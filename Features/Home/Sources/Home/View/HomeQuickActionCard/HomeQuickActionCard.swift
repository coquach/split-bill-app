//
//  HomeQuickActionCard.swift
//  Home
//
//  Created by Co Quach on 28/9/26.
//

import SwiftUI
import SystemDesign

struct HomeQuickActions: View {

    let onTransfer: () -> Void
    let onSplit: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.md) {

            HomeQuickActionCard(
                icon: "arrow.up.right",
                title: "Transfer",
                subtitle: "Send money",
                tint: Color.appInfoBackground,
                action: onTransfer
            )

            HomeQuickActionCard(
                icon: "qrcode",
                title: "Split",
                subtitle: "Share a bill",
                tint: Color.appSuccessBackground,
                action: onSplit
            )
        }
    }
}

private struct HomeQuickActionCard: View {

    let icon: String
    let title: String
    let subtitle: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(
                alignment: .leading,
                spacing: AppSpacing.sm
            ) {
                Image(systemName: icon)
                    .font(
                        .system(
                            size: 20,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(Color.appPrimary)
                    .frame(
                        width: 48,
                        height: 48
                    )
                    .background(tint)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: AppRadius.md,
                            style: .continuous
                        )
                    )

                VStack(
                    alignment: .leading,
                    spacing: 2
                ) {
                    Text(title)
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(
                            Color.appTextPrimary
                        )

                    Text(subtitle)
                        .font(AppTypography.caption)
                        .foregroundStyle(
                            Color.appTextTertiary
                        )
                }
            }
            .frame(
                maxWidth: .infinity,
                minHeight: 142,
                alignment: .leading
            )
            .padding(AppSpacing.md)
            .background(
                Color.appSurfacePrimary
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppRadius.xl,
                    style: .continuous
                )
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: AppRadius.xl,
                    style: .continuous
                )
                .stroke(
                    Color.appBorderDefault,
                    lineWidth: 1
                )
            }
        }
        .buttonStyle(.plain)
    }
}
