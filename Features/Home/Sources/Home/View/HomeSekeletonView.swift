//
//  HomeSekeletonView.swift
//  Home
//
//  Created by Co Quach on 28/9/26.
//

import SwiftUI
import SystemDesign

struct HomeSkeletonView: View {

    var body: some View {
        ScrollView(
            showsIndicators: false
        ) {
            VStack(
                alignment: .leading,
                spacing: AppSpacing.xl
            ) {

                HomeProfileHeaderSkeleton()

                HomeBalanceCardSkeleton()

                HomeQuickActionsSkeleton()

                HomeTransactionsSkeleton()
            }
            .padding(
                .horizontal,
                AppSpacing.xl
            )
            .padding(
                .top,
                AppSpacing.sm
            )
            .padding(
                .bottom,
                140
            )
        }
        .background(
            Color.appBackground
        )
    }
}
