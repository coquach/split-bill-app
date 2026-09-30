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
        HStack(spacing: 0) {

            HomeQuickActionCard(
                icon: "arrow.up.right",
                title: "Transfer",
                tint: Color.appPrimary,
                action: onTransfer
            )

            HomeQuickActionCard(
                icon: "qrcode",
                title: "Split",
                tint: Color.appPrimary,
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
                    .foregroundStyle(Color.appBackground)
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
        }
        .buttonStyle(.plain)
    }
}
