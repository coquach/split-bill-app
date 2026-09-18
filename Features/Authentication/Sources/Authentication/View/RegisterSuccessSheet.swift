//
//  RegisterSuccessSheet.swift
//  Authentication
//
//  Created by Co Quach on 18/9/26.
//

import SwiftUI
import SystemDesign

public struct RegisterSuccessSheet: View {

    private let email: String?
    private let onContinue: () -> Void

    public init(
        email: String? = nil,
        onContinue: @escaping () -> Void
    ) {
        self.email = email
        self.onContinue = onContinue
    }

    public var body: some View {
        VStack(spacing: AppSpacing.lg) {

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.appPrimary)

            VStack(spacing: AppSpacing.sm) {
                Text("Account created")
                    .font(AppTypography.title)
                    .foregroundStyle(Color.appOnSurface)

                Text(message)
                    .font(AppTypography.body)
                    .foregroundStyle(Color.appSecondary)
                    .multilineTextAlignment(.center)
            }

            AppButton(
                title: "Continue",
                style: .accent,
                action: onContinue
            )
        }
        .padding(.horizontal, AppSpacing.xl)
        .padding(.vertical, AppSpacing.xxl)
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.visible)
    }

    private var message: String {
        guard let email, !email.isEmpty else {
            return "Your account has been created successfully. Check your email if verification is required."
        }

        return "Your account has been created. Check \(email) if email verification is required."
    }
}
