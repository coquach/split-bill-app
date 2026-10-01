//
//  PillNavItem.swift
//  SystemDesign
//
//  Created by Dinh Long on 26/9/26.
//


import SwiftUI

struct AppNavItem: Identifiable, Equatable {
    let id: String
    let icon: String    
    let label: String
}

public struct AppMainBottomNavigation: View {

    private let items: [AppNavItem] = [
        AppNavItem(id: "home", icon: "house.fill", label: "Home"),
        AppNavItem(id: "history", icon: "clock.fill", label: "History"),
        AppNavItem(id: "profile", icon: "person.fill", label: "Profile"),
    ]

    @Binding private var selectedID: String

    public init(selectedID: Binding<String>) {
        self._selectedID = selectedID
    }

    public var body: some View {
        HStack(spacing: AppSpacing.lg) {
            ForEach(items) { item in
                let isSelected = item.id == selectedID

                Button {
                    selectedID = item.id
                } label: {
                    VStack(spacing: AppSpacing.xxs) {
                        Image(systemName: item.icon)
                            .font(.system(size: 20))
                        Text(item.label)
                            .font(AppTypography.caption)
                    }
                    .foregroundStyle(
                        isSelected ? Color.appPrimaryContainer : Color.appPrimaryContainer.opacity(0.4)
                    )
                }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.sm)
        .background(Color.appOnSurface)
        .clipShape(Capsule())
    }
}
