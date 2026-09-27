//
//  AppSecureField.swift
//  SystemDesign
//
//  Created by Co Quach on 18/9/26.
//
import SwiftUI

public struct AppSecureField: View {

    private let title: String
    private let placeholder: String
    private let errorMessage: String?
    private let leadingIcon: String?

    @Binding
    private var text: String

    @State
    private var isPasswordVisible = false

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


                Group {
                    if isPasswordVisible {
                        TextField(
                            placeholder,
                            text: $text
                        )
                    } else {
                        SecureField(
                            placeholder,
                            text: $text
                        )
                    }
                }
                .font(AppTypography.body)
                .foregroundStyle(Color.appTextPrimary)
                .tint(Color.appPrimary)
                .textInputAutocapitalization(.never)
                .textContentType(.password)

                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(
                        systemName: isPasswordVisible
                            ? "eye.slash"
                            : "eye"
                    )
                    .font(
                        .system(
                            size: 16,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(Color.appTextSecondary)
                    .frame(
                        width: 36,
                        height: 36
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    isPasswordVisible
                        ? "Hide password"
                        : "Show password"
                )
            }
            .padding(.leading, AppSpacing.md)
            .padding(.trailing, AppSpacing.xs)
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
