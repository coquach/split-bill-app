import SwiftUI

/// A circular ring showing a percentage — e.g. how much of a split has
/// been paid — used on the "Split Active" transaction detail variant.
public struct CircularProgressRing: View {
    private let progress: Double // 0.0 to 1.0

    public init(progress: Double) {
        self.progress = min(max(progress, 0), 1)
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(Color.appSurface, lineWidth: 6)

            Circle()
                // `.trim` draws only part of the circle's outline — from
                // 0% to `progress` of the way around — instead of the
                // whole thing, which is what makes it look like it's
                // "filling up."
                .trim(from: 0, to: progress)
                .stroke(Color.appPrimaryContainer, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                // A circle's trim normally starts at the 3 o'clock
                // position; rotating -90° moves the start to 12 o'clock,
                // which reads more naturally as a progress ring.
                .rotationEffect(.degrees(-90))

            Text("\(Int(progress * 100))%")
                .font(AppTypography.label)
                .foregroundStyle(Color.appOnSurface)
        }
    }
}
