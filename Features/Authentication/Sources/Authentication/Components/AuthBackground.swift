//
//  AuthBackground.swift
//  Authentication
//
//  Created by Co Quach on 26/9/26.
//

import SwiftUI
import SystemDesign

struct AuthBackground: View {

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            Circle()
                .fill(
                    Color.appPrimary
                        .opacity(0.12)
                )
                .frame(width: 320, height: 320)
                .blur(radius: 10)
                .offset(
                    x: 150,
                    y: -260
                )

            Circle()
                .fill(
                    Color.appSecondary
                        .opacity(0.16)
                )
                .frame(width: 300, height: 300)
                .blur(radius: 20)
                .offset(
                    x: -170,
                    y: 300
                )
        }
    }
}
