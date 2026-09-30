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
        // Cards hug their content and the pair is centered, so the two buttons sit close together
        HStack(spacing: AppSpacing.xs) {

            HomeQuickActionCard(
                icon: "arrow.up.right",
                title: "Transfer",
                accessibilityID: UITestID.homeTransferAction,
                tint: Color.appPrimary,
                action: onTransfer
            )

            HomeQuickActionCard(
                icon: "person.2.fill",
                title: "Split",
                accessibilityID: UITestID.homeSplitAction,
                tint: Color.appPrimary,
                action: onSplit
            )
        }
        .frame(maxWidth: .infinity)
    }
}

private struct HomeQuickActionCard: View {

    let icon: String
    let title: String
    let tint: Color
    var accessibilityID: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            // Circle is 62pt; icon, label, gap and padding are scaled to match
            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(
                        .system(
                            size: 26,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(Color.appBackground)
                    .frame(
                        width: 62,
                        height: 62
                    )
                    .background(tint)
                    .clipShape(Circle())

                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    // Same width as the circle; shrinks slightly if the word would overflow it
                    .frame(width: 62)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .foregroundStyle(
                        Color.appTextPrimary
                    )
            }
            .padding(AppSpacing.lg)
        }
        .buttonStyle(.plain)
        .accessibilityID(accessibilityID)
    }
}
