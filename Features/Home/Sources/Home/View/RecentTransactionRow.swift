//
//  RecentTransactionRow.swift
//  Home
//
//  Created by Co Quach on 18/9/26.
//

import SwiftUI
import SystemDesign

struct RecentTransactionRow: View {

    let transaction: HomeMockData.Transaction

    var body: some View {
        HStack(spacing: AppSpacing.sm) {

            icon

            VStack(
                alignment: .leading,
                spacing: 4
            ) {
                Text(transaction.title)
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(
                        Color.appOnSurface
                    )
                    .lineLimit(1)

                Text(transaction.subtitle)
                    .font(AppTypography.caption)
                    .foregroundStyle(
                        Color.appSecondary
                    )
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            HStack(spacing: 4) {
                Text(transaction.amount)
                    .font(
                        .system(
                            size: 18,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(
                        transaction.isIncome
                        ? Color.appSuccess
                            : Color.appOnSurface
                    )

                Text("VND")
                    .font(AppTypography.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        transaction.isIncome
                            ? Color.appSuccess
                            : Color.appOnSurface
                    )
            }

            Image(systemName: "chevron.right")
                .font(
                    .system(
                        size: 16,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    Color.appSecondary
                )
        }
        .padding(AppSpacing.md)
        .background(Color.appSurface)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppRadius.lg,
                style: .continuous
            )
        )
        .shadow(
            color: .black.opacity(0.04),
            radius: 8,
            y: 2
        )
    }

    private var icon: some View {
        Image(systemName: iconName)
            .font(.system(size: 20))
            .foregroundStyle(iconForeground)
            .frame(
                width: 48,
                height: 48
            )
            .background(iconBackground)
            .clipShape(Circle())
    }

    private var iconName: String {
        switch transaction.icon {
        case .person:
            "person.fill"

        case .coffee:
            "cup.and.saucer.fill"

        case .wifi:
            "wifi.router.fill"
        }
    }

    private var iconBackground: Color {
        switch transaction.icon {
        case .person:
            Color(red: 0.95, green: 0.89, blue: 0.80)

        case .coffee:
            Color(red: 0.96, green: 0.90, blue: 0.82)

        case .wifi:
            Color(red: 0.84, green: 0.88, blue: 1.0)
        }
    }

    private var iconForeground: Color {
        switch transaction.icon {
        case .person:
            Color.appOnSurface

        case .coffee:
            Color.appOnSurface

        case .wifi:
            Color.appSecondary
        }
    }
}
