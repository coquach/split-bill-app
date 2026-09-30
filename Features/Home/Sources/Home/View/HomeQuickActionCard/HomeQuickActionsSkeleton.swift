//
//  HomeQuickActionsSkeleton.swift
//  Home
//
//  Created by Co Quach on 28/9/26.
//

import SwiftUI
import SystemDesign

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
        VStack(spacing: AppSpacing.sm) {
            SkeletonCircle(size: 48)

            SkeletonView(
                width: 80,
                height: 18
            )
        }
        .frame(maxWidth: .infinity)
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
