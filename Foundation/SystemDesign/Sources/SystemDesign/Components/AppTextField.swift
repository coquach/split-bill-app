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
    private let leadingIcon: String?
    @Binding
    private var text: String

    public init(
        title: String,
        placeholder: String,
        text: Binding<String>,
        errorMessage: String? = nil,
        leadingIcon: String? = nil,
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.errorMessage = errorMessage
        self.leadingIcon = leadingIcon
    }

    public var body: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.xs
        ) {
            Text(title)
                .font(AppTypography.label)
                .foregroundStyle(Color.appTextPrimary)

            HStack(spacing: AppSpacing.sm) {
                if let leadingIcon {
                    Image(systemName: leadingIcon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.appTextSecondary)
                        .frame(
                            width: 20,
                            height: 20
                        )
                }

                TextField(
                    placeholder,
                    text: $text
                )
                .font(AppTypography.body)
                .foregroundStyle(Color.appTextPrimary)
                .tint(Color.appPrimary)
                .textInputAutocapitalization(.never)
                .padding(.horizontal, AppSpacing.md)
                .frame(height: 52)
                .background {
                    RoundedRectangle(
                        cornerRadius: AppRadius.lg,
                        style: .continuous
                    )
                    .fill(Color.appSurfacePrimary)
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

            }
            
            if let errorMessage {
                Text(errorMessage)
                    .font(AppTypography.caption)
                    .foregroundStyle(Color.appError)
            }

        }
    }

    private var borderColor: Color {
        if errorMessage != nil {
            return .appError
        }

        return .appBorderDefault
    }
}
