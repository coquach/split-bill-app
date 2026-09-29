//
//  ProfileInfoRow.swift
//  Profile
//
//  Created by Co Quach on 28/9/26.
//
import SwiftUI
import SystemDesign

public struct ProfileInfoRow: View {
    let icon: String
    let title: String
    let value: String

    public var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.appTextSecondary)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(title)
                    .font(AppTypography.caption)
                    .foregroundStyle(Color.appTextTertiary)

                Text(value)
                    .font(AppTypography.body)
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(2)
            }

            Spacer()
        }
    }
}
