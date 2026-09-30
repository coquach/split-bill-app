//
//  SettingsRow.swift
//  SystemDesign
//

import SwiftUI

/// One tappable row in a settings-style list: a round icon, a label and a trailing chevron.
/// Put several inside a card and set `showsTopDivider` on every row after the first.
public struct SettingsRow: View {

    private let icon: String
    private let title: String
    private let showsTopDivider: Bool
    private let action: () -> Void

    public init(
        icon: String,
        title: String,
        showsTopDivider: Bool = false,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.showsTopDivider = showsTopDivider
        self.action = action
    }

    public var body: some View {
        VStack(spacing: 0) {
            if showsTopDivider {
                Rectangle()
                    .fill(Color.appBorderDefault)
                    .frame(height: 1)
            }

            Button(action: action) {
                HStack(spacing: AppSpacing.sm) {
                    Circle()
                        .fill(Color.appIconBadge)
                        .frame(width: 44, height: 44)
                        .overlay {
                            Image(systemName: icon)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.appTextPrimary)
                        }

                    Text(title)
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(Color.appTextPrimary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.appTextSecondary)
                }
                .padding(.vertical, AppSpacing.sm)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}
