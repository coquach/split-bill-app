//
//  DividedInfoStack.swift
//  SystemDesign
//
//  Created by Dinh Long on 28/9/26.
//

import SwiftUI

/// A label/value row.
public struct InfoRow: View {
    private let label: String
    private let value: String

    public init(label: String, value: String) {
        self.label = label
        self.value = value
    }

    public var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(AppTypography.body)
                .foregroundStyle(Color.appTextSecondary)

            Spacer()

            Text(value)
                .font(AppTypography.bodyMedium)
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.trailing)
        }
    }
}

/// Stacked label/value rows with a hairline between each pair — never above
/// the first or below the last.
///
/// Several screens draw this "rows in a white card, separated by a thin rule"
/// pattern, and each one used to hand-draw its own `Divider()`, which is how
/// the weights drifted apart. The rule belongs to the stack, not the screen.
///
/// Takes its rows as data rather than a `ViewBuilder`: it keeps the divider
/// logic a plain loop over an array, and avoids `Group(subviews:)`, which
/// needs iOS 18 while this package supports 17.
public struct DividedInfoStack: View {

    public struct Row {
        let label: String
        let value: String

        public init(label: String, value: String) {
            self.label = label
            self.value = value
        }
    }

    private let rows: [Row]

    public init(_ rows: [Row]) {
        self.rows = rows
    }

    public var body: some View {
        VStack(spacing: AppSpacing.sm) {
            ForEach(rows.indices, id: \.self) { index in
                if index > 0 {
                    Rectangle()
                        .fill(Color.appBorderDefault)
                        .frame(height: 1)
                }

                InfoRow(
                    label: rows[index].label,
                    value: rows[index].value
                )
            }
        }
    }
}
