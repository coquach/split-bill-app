//
//  HomeFloatNavigation.swift
//  Home
//
//  Created by Co Quach on 28/9/26.
//

import SwiftUI
import SystemDesign

struct HomeFloatingNavigation: View {

    let onSplit: () -> Void
    let onProfile: () -> Void

    var body: some View {
        HStack(
            spacing: AppSpacing.xxl
        ) {

            Image(systemName: "house.fill")
                .font(
                    .system(
                        size: 20,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    Color.appPrimary
                )
                .frame(
                    width: 40,
                    height: 32
                )

            Button(action: onSplit) {
                Image(
                    systemName: "qrcode.viewfinder"
                )
                .font(
                    .system(
                        size: 33,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    Color.appTextOnPrimary
                )
                .frame(
                    width: 66,
                    height: 66
                )
                .background(
                    Color.appPrimary
                )
                .clipShape(Circle())
                .shadow(
                    color: Color.appPrimary.opacity(
                        0.22
                    ),
                    radius: 6,
                    y: 3
                )
            }
            .buttonStyle(.plain)

            Button(action: onProfile) {
                Image(
                    systemName:
                        "person.crop.circle"
                )
                .font(
                    .system(
                        size: 23,
                        weight: .medium
                    )
                )
                .foregroundStyle(
                    Color.appTextSecondary
                )
                .frame(
                    width: 40,
                    height: 32
                )
            }
            .buttonStyle(.plain)
        }
        .padding(
            .horizontal,
            AppSpacing.xl
        )
        .padding(
            .vertical,
            AppSpacing.sm
        )
        .background(
            Color.appSurfacePrimary
        )
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .stroke(
                    Color.appBorderDefault,
                    lineWidth: 1
                )
        }
        .shadow(
            color: Color.black.opacity(0.08),
            radius: 8,
            y: 3
        )
        .padding(
            .horizontal,
            AppSpacing.xl
        )
        .padding(
            .bottom,
            AppSpacing.sm
        )
    }
}
