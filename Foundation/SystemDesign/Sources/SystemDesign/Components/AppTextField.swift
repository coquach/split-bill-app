//
//  AppTextField.swift
//  SystemDesign
//
//  Created by Co Quach on 18/9/26.
//
import SwiftUI

public struct AppTextField: View {

    private let title: String
    private let placeholder: String
    private let errorMessage: String?

    @Binding
    private var text: String

    public init(
        title: String,
        placeholder: String,
        text: Binding<String>,
        errorMessage: String? = nil
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.errorMessage = errorMessage
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {

            Text(title)
                .font(AppTypography.label)
                .foregroundStyle(Color.appOnSurface)

            TextField(
                placeholder,
                text: $text
            )
            .font(AppTypography.body)
            .foregroundStyle(Color.appOnSurface)
            .textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)
            .padding(.horizontal, AppSpacing.md)
            .frame(height: 52)
            .background {
                RoundedRectangle(
                    cornerRadius: AppRadius.lg,
                    style: .continuous
                )
                .fill(Color.appSurface)
            }
            .overlay {
                RoundedRectangle(
                    cornerRadius: AppRadius.lg,
                    style: .continuous
                )
                .stroke(
                    borderColor,
                    lineWidth: errorMessage == nil ? 1 : 1.5
                )
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(AppTypography.caption)
                    .foregroundStyle(Color.appError)
            }
        }
    }

    private var borderColor: Color {
        errorMessage == nil
            ? Color.appOnSurface.opacity(0.08)
            : Color.appError
    }
}
