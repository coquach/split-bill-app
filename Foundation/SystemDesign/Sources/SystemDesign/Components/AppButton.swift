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
    private let icon: String?
    private let isLoading: Bool
    private let action: () -> Void

    /// - Parameter icon: optional SF Symbol drawn before the label, e.g.
    ///   "qrcode" on Generate QR or "square.and.arrow.up" on Share.
    public init(
        title: String,
        style: Style = .primary,
        icon: String? = nil,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.icon = icon
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
                    HStack(spacing: AppSpacing.xs) {
                        if let icon {
                            Image(systemName: icon)
                                .font(.system(size: 16, weight: .medium))
                        }
                        Text(title)
                            .font(AppTypography.bodyMedium)
                    }
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
        .disabled(isLoading)
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return .appPrimary

        case .accent:
            return .appSubtle

        case .secondary:
            return .appSurfacePrimary
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .appTextOnPrimary

        case .accent:
            return .appTextPrimary

        case .secondary:
            return .appPrimary
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
