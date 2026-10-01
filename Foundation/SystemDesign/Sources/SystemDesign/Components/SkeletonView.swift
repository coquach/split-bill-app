//
//  SkeletonView.swift
//  SystemDesign
//
//  Created by Co Quach on 28/9/26.
//

import SwiftUI

public struct SkeletonView: View {

    private let width: CGFloat?
    private let height: CGFloat
    private let cornerRadius: CGFloat

    public init(
        width: CGFloat? = nil,
        height: CGFloat,
        cornerRadius: CGFloat = AppRadius.sm
    ) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        RoundedRectangle(
            cornerRadius: cornerRadius,
            style: .continuous
        )
        .fill(
            Color.appTextTertiary.opacity(0.12)
        )
        .frame(
            width: width,
            height: height
        )
        .redacted(reason: .placeholder)
    }
}

public struct SkeletonCircle: View {

    private let size: CGFloat

    public init(size: CGFloat) {
        self.size = size
    }

    public var body: some View {
        Circle()
            .fill(
                Color.appTextTertiary.opacity(0.12)
            )
            .frame(
                width: size,
                height: size
            )
    }
}

public struct SkeletonCapsule: View {

    private let width: CGFloat
    private let height: CGFloat

    public init(
        width: CGFloat,
        height: CGFloat
    ) {
        self.width = width
        self.height = height
    }

    public var body: some View {
        Capsule()
            .fill(
                Color.appTextTertiary.opacity(0.12)
            )
            .frame(
                width: width,
                height: height
            )
    }
}
