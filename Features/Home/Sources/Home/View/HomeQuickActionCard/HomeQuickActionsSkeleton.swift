//
//  HomeQuickActionsSkeleton.swift
//  Home
//
//  Created by Co Quach on 28/9/26.
//

import SwiftUI
import SystemDesign
import CommonUi

struct HomeQuickActionsSkeleton: View {

    var body: some View {
        HStack(
            spacing: AppSpacing.md
        ) {
            card

            card
        }
    }

    private var card: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.sm
        ) {
            SkeletonView(
                width: 48,
                height: 48,
                cornerRadius: AppRadius.md
            )

            VStack(
                alignment: .leading,
                spacing: 4
            ) {
                SkeletonView(
                    width: 80,
                    height: 18
                )

                SkeletonView(
                    width: 95,
                    height: 14
                )
            }
        }
        .frame(
            maxWidth: .infinity,
            minHeight: 142,
            alignment: .leading
        )
        .padding(AppSpacing.md)
        .background(
            Color.appSurfacePrimary
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppRadius.xl,
                style: .continuous
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: AppRadius.xl,
                style: .continuous
            )
            .stroke(
                Color.appBorderDefault,
                lineWidth: 1
            )
        }
    }
}
