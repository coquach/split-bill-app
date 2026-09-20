//
//  QuickActionCard.swift
//  Home
//
//  Created by Co Quach on 18/9/26.
//

import SwiftUI
import SystemDesign

struct QuickActionCard: View {

    enum Kind {
        case transfer
        case split
        case request
    }

    let kind: Kind
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(
                alignment: .leading,
                spacing: AppSpacing.md
            ) {
                HStack {
                    Image(systemName: icon)
                        .font(
                            .system(
                                size: 22,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(
                            iconForeground
                        )
                        .frame(
                            width: 48,
                            height: 48
                        )
                        .background(
                            iconBackground
                        )
                        .clipShape(Circle())

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(
                            iconForeground
                        )
                }

                Spacer()

                Text(title)
                    .font(
                        .system(
                            size: 17,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        foregroundColor
                    )
            }
            .padding(AppSpacing.lg)
            .frame(
                maxWidth: .infinity,
                minHeight: 178
            )
            .background(backgroundColor)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppRadius.lg,
                    style: .continuous
                )
            )
        }
        .buttonStyle(.plain)
    }

    private var title: String {
        switch kind {
        case .transfer:
            "Transfer"
        case .split:
            "Split Bill"
        case .request:
            "Request"
        }
    }

    private var icon: String {
        switch kind {
        case .transfer:
            "arrow.up.right"

        case .split:
            "arrow.up.right.and.arrow.down.left"

        case .request:
            "arrow.down.left"
        }
    }

    private var backgroundColor: Color {
        switch kind {
        case .transfer:
            Color.appPrimaryContainer

        case .split, .request:
            Color.appSurface
        }
    }

    private var foregroundColor: Color {
        switch kind {
        case .transfer:
            Color.appPrimary

        case .split, .request:
            Color.appOnSurface
        }
    }

    private var iconBackground: Color {
        switch kind {
        case .transfer:
            Color.appPrimary.opacity(0.08)

        case .split:
            Color(red: 0.65, green: 1.0, blue: 0.82)

        case .request:
            Color(red: 0.84, green: 0.88, blue: 1.0)
        }
    }

    private var iconForeground: Color {
        switch kind {
        case .transfer:
            Color.appPrimaryContainer

        case .split:
            Color.appSuccess

        case .request:
            Color.appSecondary
        }
    }
}
