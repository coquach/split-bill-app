//
//  HomeHeader.swift
//  Home
//
//  Created by Co Quach on 18/9/26.
//

import SwiftUI
import SystemDesign

struct HomeHeader: View {

    let userName: String

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.sm
        ) {
            HStack {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "wallet.pass.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.appOnSurface)
                        .frame(
                            width: 52,
                            height: 52
                        )
                        .background(
                            Color.appPrimaryContainer
                        )
                        .clipShape(Circle())

                }

                Spacer()

                HStack(spacing: AppSpacing.sm) {
                    Button {} label: {
                        Image(systemName: "bell")
                            .font(.system(size: 22))
                            .foregroundStyle(
                                Color.appOnSurface
                            )
                            .frame(
                                width: 44,
                                height: 44
                            )
                    }
                    .buttonStyle(.plain)

                    Button {} label: {
                        Image(systemName: "person.fill")
                            .foregroundStyle(
                                Color.white
                            )
                            .frame(
                                width: 44,
                                height: 44
                            )
                            .background(
                                Color.appPrimary
                            )
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }

            VStack(
                alignment: .leading,
                spacing: 4
            ) {
                Text("WELCOME BACK")
                    .font(AppTypography.label)
                    .foregroundStyle(
                        Color.appOnSurface
                    )

                HStack {
                    Text("Hi, \(userName)")
                        .font(AppTypography.title)
                        .foregroundStyle(
                            Color.appOnSurface
                        )

                }
            }
        }
    }
}


