//
//  HomeTransactionsSkeleton.swift
//  Home
//
//  Created by Co Quach on 28/9/26.
//

import SwiftUI
import SystemDesign
import CommonUi

struct HomeTransactionsSkeleton: View {

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.sm
        ) {

            HStack {
                SkeletonView(
                    width: 145,
                    height: 20
                )

                Spacer()

                SkeletonView(
                    width: 48,
                    height: 16
                )
            }
            .padding(
                .horizontal,
                AppSpacing.xs
            )

            VStack(
                spacing: AppSpacing.md
            ) {
                ForEach(
                    0..<4,
                    id: \.self
                ) { _ in
                    TransactionRowSkeleton()
                }
            }
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
}

struct TransactionRowSkeleton: View {

    public init() {}

    public var body: some View {
        HStack(
            spacing: AppSpacing.sm
        ) {

            SkeletonCircle(
                size: 44
            )

            VStack(
                alignment: .leading,
                spacing: 4
            ) {
                SkeletonView(
                    width: 90,
                    height: 16
                )

                SkeletonView(
                    width: 125,
                    height: 13
                )
            }

            Spacer()

            VStack(
                alignment: .trailing,
                spacing: 4
            ) {
                SkeletonView(
                    width: 85,
                    height: 16
                )

                SkeletonView(
                    width: 50,
                    height: 12
                )
            }
        }
    }
}
