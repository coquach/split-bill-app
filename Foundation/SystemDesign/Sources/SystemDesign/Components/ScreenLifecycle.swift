//
//  ScreenLifecycle.swift
//  SystemDesign
//
//  Created by Dinh Long on 27/9/26.
//

import SwiftUI

public struct ScreenLifecycleModifier: ViewModifier {
    let screenName: String
    let onAppear: (() -> Void)?
    let onDisappear: (() -> Void)?

    public func body(content: Content) -> some View {
        content
            .onAppear {
                print("[Lifecycle] \(screenName) appeared")
                onAppear?()
            }
            .onDisappear {
                print("[Lifecycle] \(screenName) disappeared")
                onDisappear?()
            }
    }
}

public extension View {
    func screenLifecycle(
        _ screenName: String,
        onAppear: (() -> Void)? = nil,
        onDisappear: (() -> Void)? = nil
    ) -> some View {
        modifier(ScreenLifecycleModifier(screenName: screenName, onAppear: onAppear, onDisappear: onDisappear))
    }
}
