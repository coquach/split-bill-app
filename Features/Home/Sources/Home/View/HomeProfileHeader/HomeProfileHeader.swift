//
//  HomeProfileHeader.swift
//  Home
//
//  Created by Co Quach on 27/9/26.
//

import SwiftUI
import SystemDesign

struct HomeProfileHeader: View {

    let displayName: String
//    let onSettings: () -> Void

    var body: some View {
        HStack(alignment: .center) {

            VStack(
                alignment: .leading,
                spacing: 2
            ) {
                Text("Welcome back")
                    .font(AppTypography.caption)
                    .foregroundStyle(Color.appTextTertiary)

                Text(displayName)
                    .font(AppTypography.title)
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
            }

            Spacer()

//            Button(action: onSettings) {
//                Image(systemName: "gearshape")
//                    .font(
//                        .system(
//                            size: 18,
//                            weight: .semibold
//                        )
//                    )
//                    .foregroundStyle(Color.appTextPrimary)
//                    .frame(width: 44, height: 44)
//                    .background(Color.appSurfacePrimary)
//                    .clipShape(
//                        RoundedRectangle(
//                            cornerRadius: AppRadius.md,
//                            style: .continuous
//                        )
//                    )
//                    .overlay {
//                        RoundedRectangle(
//                            cornerRadius: AppRadius.md,
//                            style: .continuous
//                        )
//                        .stroke(
//                            Color.appBorderDefault,
//                            lineWidth: 1
//                        )
//                    }
//            }
//            .buttonStyle(.plain)
        }
    }
}
