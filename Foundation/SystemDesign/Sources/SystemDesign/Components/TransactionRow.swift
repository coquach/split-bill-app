//
//  TransactionRow.swift
//  SystemDesign
//
//  Created by Dinh Long on 26/9/26.
//


import SwiftUI

public struct TransactionRow: View {

    public enum Direction {
        case incoming
        case outgoing

        var amountColor: Color {
            switch self {
            case .incoming: return Color.appSuccess
            case .outgoing: return Color.appOnSurface
            }
        }

        var amountPrefix: String {
            switch self {
            case .incoming: return "+"
            case .outgoing: return "-"
            }
        }
    }

    private let name: String
    private let subtitle: String     // "Today" or "14:32"
    private let amountText: String  
    private let direction: Direction

    public init(name: String, subtitle: String, amountText: String, direction: Direction) {
        self.name = name
        self.subtitle = subtitle
        self.amountText = amountText
        self.direction = direction
    }

    public var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Avatar(name: name, size: .medium)

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(name)
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(Color.appOnSurface)
                Text(subtitle)
                    .font(AppTypography.caption)
                    .foregroundStyle(Color.appOnSurface.opacity(0.6))
            }

            Spacer()

            Text("\(direction.amountPrefix)\(amountText)")
                .font(AppTypography.bodyMedium)
                .foregroundStyle(direction.amountColor)
        }
        .padding(.vertical, AppSpacing.xs)
    }
}
