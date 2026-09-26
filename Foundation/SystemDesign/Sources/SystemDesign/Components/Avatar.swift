//
//  Avatar.swift
//  SystemDesign
//
//  Created by Dinh Long on 26/9/26.
//


import SwiftUI

public struct Avatar: View {

    public enum Size {
        case small   // 32pt — compact rows / split participant list
        case medium  // 44pt — standard list rows, transaction history
        case large   // 64pt — screen headers,transfer confirm

        var diameter: CGFloat {
            switch self {
            case .small: return 32
            case .medium: return 44
            case .large: return 64
            }
        }

        // Bigger circle needs bigger text, so size picks the font too.
        var font: Font {
            switch self {
            case .small: return AppTypography.caption
            case .medium: return AppTypography.label
            case .large: return AppTypography.title
            }
        }
    }

    // The full name to show initials for "Nguyen Van A".
    private let name: String
    private let size: Size

    public init(name: String, size: Size = .medium) {
        self.name = name
        self.size = size
    }

    public var body: some View {
        Circle()
            .fill(Color.appPrimaryContainer)
            .frame(width: size.diameter, height: size.diameter)
            .overlay {
                Text(initials)
                    .font(size.font)
                    .foregroundStyle(Color.appOnSurface)
            }
    }

    // Takes the first letter of up to the first 2 words in the name.
    // "Nguyen Van A" -> "NV", "Long" -> "L".
    private var initials: String {
        let words = name.split(separator: " ")
        let letters = words.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }
}
