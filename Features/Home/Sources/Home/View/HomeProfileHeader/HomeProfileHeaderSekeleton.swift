//
//  HomeProfileHeaderSekeleton.swift
//  Home
//
//  Created by Co Quach on 28/9/26.
//

import SwiftUI
import SystemDesign

struct HomeProfileHeaderSkeleton: View {

    var body: some View {
        HStack {
            VStack(
                alignment: .leading,
                spacing: AppSpacing.xs
            ) {
                SkeletonView(
                    width: 90,
                    height: 14
                )

                SkeletonView(
                    width: 130,
                    height: 24
                )
            }

            Spacer()

//            SkeletonView(
//                width: 44,
//                height: 44,
//                cornerRadius: AppRadius.md
//            )
        }
    }
}
