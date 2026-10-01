//
//  AppModal.swift
//  SystemDesign
//
//  Created by Dinh Long on 26/9/26.
//


import SwiftUI

public struct AppModal<Actions: View>: View {
    /// What the modal is about — drives the icon tint. Defaults to `.error`
    /// so existing error call sites need no change; confirmation modals
    /// (cancel, logout) pass `.warning` and success ones `.success`.
    public enum Style {
        case error
        case warning
        case success

        var iconColor: Color {
            switch self {
            case .error: .appError
            case .warning: .appWarning
            case .success: .appSuccess
            }
        }
    }

    private let icon: Image?
    private let style: Style
    private let title: String
    private let message: String
    private let accessibilityID: String?
    private let actions: Actions

    public init(
        icon: Image? = nil,
        style: Style = .error,
        title: String,
        message: String,
        accessibilityID: String? = nil,
        @ViewBuilder actions: () -> Actions
    ) {
        self.icon = icon
        self.style = style
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
                    .foregroundStyle(style.iconColor)
            }

            Text(title)
                .font(AppTypography.title)
                .foregroundStyle(Color.appOnSurface)
                .multilineTextAlignment(.center)

            Text(message)
                .accessibilityID(UITestID.errorModalMessage)
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
        // Warm card on the app's palette; the hairline border and shadow keep
        // it floating above same-coloured content behind the scrim.
        .background(Color.appBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl))
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .strokeBorder(Color.appBorderDefault.opacity(0.5), lineWidth: 1)
        }
        .shadow(color: .appTextPrimary.opacity(0.12), radius: 24, y: 8)
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
                    Color.appScrim
                        .ignoresSafeArea()
                    content()
                }
            }
        }
    }
}
