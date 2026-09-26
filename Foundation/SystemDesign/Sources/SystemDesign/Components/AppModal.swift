//
//  AppModal.swift
//  SystemDesign
//
//  Created by Dinh Long on 26/9/26.
//


import SwiftUI

public struct AppModal<Actions: View>: View {
    private let icon: Image?
    private let title: String
    private let message: String
    private let actions: Actions

    public init(
        icon: Image? = nil,
        title: String,
        message: String,
        @ViewBuilder actions: () -> Actions
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actions = actions()
    }

    public var body: some View {
        VStack(spacing: AppSpacing.md) {
            if let icon {
                icon
                    .font(.system(size: 40))
                    .foregroundStyle(Color.appError)
            }

            Text(title)
                .font(AppTypography.title)
                .foregroundStyle(Color.appOnSurface)
                .multilineTextAlignment(.center)

            Text(message)
                .font(AppTypography.body)
                .foregroundStyle(Color.appOnSurface.opacity(0.6))
                .multilineTextAlignment(.center)

            actions
        }
        .padding(AppSpacing.xl)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl))
        .padding(.horizontal, AppSpacing.xl)
    }
}

public extension View {
    func modalOverlay<ModalContent: View>(
        isPresented: Bool,
        @ViewBuilder content: () -> ModalContent
    ) -> some View {
        self.overlay {
            if isPresented {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    content()
                }
            }
        }
    }
}
