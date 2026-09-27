//
//  AuthHeader.swift
//  Authentication
//
//  Created by Co Quach on 26/9/26.
//

import SwiftUI

import SwiftUI
import SystemDesign

struct AuthHeader: View {

    let icon: String
    let title: String
    let subtitle: String
    let iconSize: CGFloat

    init(
        icon: String,
        title: String,
        subtitle: String,
        iconSize: CGFloat = 21
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.iconSize = iconSize
    }

    var body: some View {
        VStack(spacing: 0) {
            logo

            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 4)

            Text(subtitle)
                .font(.system(size: 14))
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
    }
}

// MARK: - Private

private extension AuthHeader {

    var logo: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appSurfacePrimary)
                .frame(width: 64, height: 64)
                .shadow(
                    color: .black.opacity(0.08),
                    radius: 10,
                    y: 5
                )

            Image(systemName: icon)
                .font(
                    .system(
                        size: iconSize,
                        weight: .semibold
                    )
                )
                .foregroundStyle(Color.appPrimary)
        }
        .padding(.bottom, 14)
    }
}
