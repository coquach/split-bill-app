//
//  HomeBalanceCardSkeleton.swift
//  Home
//
//  Created by Co Quach on 28/9/26.
//

import SwiftUI
import SystemDesign
import CommonUi

struct HomeBalanceCardSkeleton: View {

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 0
        ) {

            HStack {
                SkeletonView(
                    width: 120,
                    height: 12
                )

                Spacer()

                SkeletonCapsule(
                    width: 70,
                    height: 25
                )
            }

            Spacer()

            SkeletonView(
                width: 190,
                height: 36,
                cornerRadius: AppRadius.sm
            )

            Spacer()

            HStack {
                SkeletonView(
                    width: 110,
                    height: 16
                )

                Spacer()

                SkeletonView(
                    width: 100,
                    height: 14
                )
            }
        }
        .padding(AppSpacing.xl)
        .frame(
            maxWidth: .infinity,
            minHeight: 250
        )
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
