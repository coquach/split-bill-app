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
    private let accessibilityID: String?
    private let actions: Actions

    public init(
        icon: Image? = nil,
        title: String,
        message: String,
        accessibilityID: String? = nil,
        @ViewBuilder actions: () -> Actions
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.accessibilityID = accessibilityID
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
        // children: .contain keeps the modal an addressable container (its
        // title identifier) WITHOUT collapsing its buttons into it — a bare
        // identifier on a plain VStack makes XCUITest see the modal as one
        // opaque element and the action buttons inside become unreachable.
        .accessibilityElement(children: .contain)
        .accessibilityID(accessibilityID)
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
