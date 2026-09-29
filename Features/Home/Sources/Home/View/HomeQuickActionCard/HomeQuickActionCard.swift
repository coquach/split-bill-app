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
                tint: Color.appInfoBackground,
                action: onTransfer
            )

            HomeQuickActionCard(
                icon: "qrcode",
                title: "Split",
                tint: Color.appInfoBackground,
                action: onSplit
            )
        }
    }
}

private struct HomeQuickActionCard: View {

    let icon: String
    let title: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.sm) {
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
                    .clipShape(Circle())

                Text(title)
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(
                        Color.appTextPrimary
                    )
            }
            .frame(maxWidth: .infinity)
            .padding(AppSpacing.md)
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
