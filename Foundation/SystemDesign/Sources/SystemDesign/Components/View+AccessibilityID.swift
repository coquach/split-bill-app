//
//  View+AccessibilityID.swift
//  SystemDesign
//

import SwiftUI

public extension View {
    /// Applies an accessibility identifier only when one is provided, so
    /// components can expose an optional `accessibilityID` parameter without
    /// polluting the accessibility tree with `nil` identifiers.
    @ViewBuilder
    func accessibilityID(_ id: String?) -> some View {
        if let id {
            accessibilityIdentifier(id)
        } else {
            self
        }
    }
}
