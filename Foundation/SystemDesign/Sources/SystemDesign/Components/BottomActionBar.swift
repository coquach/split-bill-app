//
//  BottomActionBar.swift
//  SystemDesign
//
//  Created by Dinh Long on 28/9/26.
//

import SwiftUI

/// The pinned bottom section that holds a screen's actions.
///
/// Every button in the Transfer flow lives here rather than inline in the
/// content, so spacing, width and the distance from the home indicator are
/// identical on every screen — previously each screen positioned its own
/// buttons and they all drifted slightly apart.
///
/// Takes one required action and one optional second one. That covers every
/// screen in the flow, and keeping it to a concrete two-slot API (rather than
/// a generic `ViewBuilder`) means a reader can see exactly what a bar can
/// contain without opening the call site.
///
/// Attach it with `.safeAreaInset(edge: .bottom, spacing: 0)`.
public struct BottomActionBar: View {

    /// One button in the bar. `isEnabled` drives both the tap and the dimmed
    /// look, so a call site can't accidentally set one without the other.
    public struct Action {
        let title: String
        let style: AppButton.Style
        let icon: String?
        let isEnabled: Bool
        let isLoading: Bool
        let handler: () -> Void

        public init(
            title: String,
            style: AppButton.Style = .primary,
            icon: String? = nil,
            isEnabled: Bool = true,
            isLoading: Bool = false,
            handler: @escaping () -> Void
        ) {
            self.title = title
            self.style = style
            self.icon = icon
            self.isEnabled = isEnabled
            self.isLoading = isLoading
            self.handler = handler
        }
    }

    /// How the two actions sit relative to each other. Stacked is the
    /// default because most screens have one clear primary action; side by
    /// side is for genuine peers, like Save and Share on Split QR.
    public enum Layout {
        case stacked
        case sideBySide
    }

    /// A plain text link below the buttons — an exit, not a call to action,
    /// so it deliberately has no button chrome.
    public struct TextLink {
        let title: String
        let handler: () -> Void

        public init(title: String, handler: @escaping () -> Void) {
            self.title = title
            self.handler = handler
        }
    }

    private let primary: Action
    private let secondary: Action?
    private let layout: Layout
    private let link: TextLink?
    private let background: Color

    /// `background` is a parameter only because Transfer Success sits on a
    /// gradient and needs the bar to disappear into it — everywhere else the
    /// default is correct.
    public init(
        primary: Action,
        secondary: Action? = nil,
        layout: Layout = .stacked,
        link: TextLink? = nil,
        background: Color = .appBackground
    ) {
        self.primary = primary
        self.secondary = secondary
        self.layout = layout
        self.link = link
        self.background = background
    }

    public var body: some View {
        VStack(spacing: AppSpacing.sm) {
            switch layout {
            case .stacked:
                button(for: primary)
                if let secondary {
                    button(for: secondary)
                }

            case .sideBySide:
                HStack(spacing: AppSpacing.sm) {
                    // Secondary leads so the primary lands under the thumb
                    // on the trailing side, matching the reference.
                    if let secondary {
                        button(for: secondary)
                    }
                    button(for: primary)
                }
            }

            if let link {
                Button(action: link.handler) {
                    Text(link.title)
                        .font(AppTypography.body)
                        .foregroundStyle(Color.appTextSecondary)
                }
                .buttonStyle(.plain)
                .padding(.top, AppSpacing.xxs)
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.sm)
        .padding(.bottom, AppSpacing.xs)
        .background(background)
    }

    private func button(for action: Action) -> some View {
        AppButton(
            title: action.title,
            style: action.style,
            icon: action.icon,
            isLoading: action.isLoading,
            action: action.handler
        )
        .disabled(!action.isEnabled || action.isLoading)
        .opacity(action.isEnabled ? 1 : 0.35)
    }
}
