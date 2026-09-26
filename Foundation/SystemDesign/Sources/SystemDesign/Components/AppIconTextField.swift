//
//  AppIconTextField.swift
//  SystemDesign
//
//  Created by Dinh Long on 26/9/26.
//

import SwiftUI

public struct AppIconTextField: View {
    private let icon: String?
    private let placeholder: String

    @Binding private var text: String

    @FocusState private var isFocused: Bool

    public init(icon: String? = nil, placeholder: String, text: Binding<String>) {
        self.icon = icon
        self.placeholder = placeholder
        self._text = text
    }

    public var body: some View {
        HStack(spacing: AppSpacing.sm) {
            if let icon {
                Image(systemName: icon)
                    .foregroundStyle(Color.appOnSurface.opacity(0.5))
            }

            TextField(placeholder, text: $text)
                .font(AppTypography.body)
                .foregroundStyle(Color.appOnSurface)
                .focused($isFocused)
        }
        .padding(.horizontal, AppSpacing.md)
        .frame(height: 52)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .strokeBorder(
                    isFocused ? Color.appPrimaryContainer : Color.clear,
                    lineWidth: 2
                )
        }
    }
}
