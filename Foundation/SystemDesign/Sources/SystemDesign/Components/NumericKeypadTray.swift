//
//  NumericKeypadTray.swift
//  SystemDesign
//
//  Created by Dinh Long on 27/9/26.
//

import SwiftUI

/// A custom in-app numeric keypad (3 columns x 4 rows: 1-9, blank, 0,
/// backspace) for screens that fully suppress the system keyboard - e.g.
/// PIN verification. Pure input source: no internal state, just reports
/// taps outward via `onDigit`/`onBackspace`. Cell size is derived from
/// the available width via `aspectRatio`, not a fixed pixel size, so it
/// scales across device sizes.
public struct NumericKeypadTray: View {
    private let onDigit: (Int) -> Void
    private let onBackspace: () -> Void

    public init(onDigit: @escaping (Int) -> Void, onBackspace: @escaping () -> Void) {
        self.onDigit = onDigit
        self.onBackspace = onBackspace
    }

    private enum Key: Identifiable {
        case digit(Int, String)
        case backspace
        case blank

        var id: String {
            switch self {
            case .digit(let value, _): return "digit-\(value)"
            case .backspace: return "backspace"
            case .blank: return "blank"
            }
        }
    }

    private static let rows: [[Key]] = [
        [.digit(1, ""), .digit(2, "ABC"), .digit(3, "DEF")],
        [.digit(4, "GHI"), .digit(5, "JKL"), .digit(6, "MNO")],
        [.digit(7, "PQRS"), .digit(8, "TUV"), .digit(9, "WXYZ")],
        [.blank, .digit(0, ""), .backspace],
    ]

    public var body: some View {
        VStack(spacing: AppSpacing.sm) {
            ForEach(Self.rows.indices, id: \.self) { rowIndex in
                HStack(spacing: AppSpacing.sm) {
                    ForEach(Self.rows[rowIndex]) { key in
                        keyView(key)
                    }
                }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.md)
        .padding(.bottom, AppSpacing.lg)
        .background(Color.appKeypadTray)
    }

    @ViewBuilder
    private func keyView(_ key: Key) -> some View {
        switch key {
        case .digit(let value, let letters):
            Button {
                onDigit(value)
            } label: {
                VStack(spacing: 2) {
                    Text("\(value)")
                        .font(AppTypography.title)
                        .foregroundStyle(Color.appOnSurface)
                    if !letters.isEmpty {
                        Text(letters)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color.appSecondary)
                            .tracking(1)
                    }
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(4.0 / 3.0, contentMode: .fit)
                .background(Color.appSurface)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
            }
            .buttonStyle(.plain)

        case .backspace:
            Button(action: onBackspace) {
                Image(systemName: "delete.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.appOnSurface)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(4.0 / 3.0, contentMode: .fit)
                    .background(Color.appSurface)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
            }
            .buttonStyle(.plain)

        case .blank:
            Color.clear
                .frame(maxWidth: .infinity)
                .aspectRatio(4.0 / 3.0, contentMode: .fit)
        }
    }
}
