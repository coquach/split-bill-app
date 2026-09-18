//
//  AppButton.swift
//  SystemDesign
//
//  Created by Co Quach on 18/9/26.
//
import SwiftUI

public struct AppButton: View {

    public enum Style {
        case primary
        case accent
        case secondary
    }

    private let title: String
    private let style: Style
    private let isLoading: Bool
    private let action: () -> Void

    public init(
        title: String,
        style: Style = .primary,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .tint(foregroundColor)
                } else {
                    Text(title)
                        .font(AppTypography.bodyMedium)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
        }
        .foregroundStyle(foregroundColor)
        .background(backgroundColor)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppRadius.lg,
                style: .continuous
            )
        )
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return .appOnSurface

        case .accent:
            return .appPrimaryContainer

        case .secondary:
            return .appSurface
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .appPrimaryContainer

        case .accent:
            return .appOnSurface

        case .secondary:
            return .appOnSurface
        }
    }
}


#Preview("Primary") {
    AppButton(
        title: "Create account",
        style: .primary
    ) {
        print("Tapped")
    }
    .padding()
}

#Preview("Accent") {
    AppButton(
        title: "Sign in",
        style: .accent
    ) {
        print("Tapped")
    }
    .padding()
}

#Preview("Loading") {
    AppButton(
        title: "Sign in",
        style: .accent,
        isLoading: true
    ) {}
    .padding()
}
