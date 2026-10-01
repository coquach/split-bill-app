import SwiftUI

/// A horizontal progress bar — the linear counterpart to
/// CircularProgressRing, for the same split-payment-progress use case.
public struct LinearProgressBar: View {
    private let progress: Double // 0.0 to 1.0

    public init(progress: Double) {
        self.progress = min(max(progress, 0), 1)
    }

    public var body: some View {
        // GeometryReader hands you the actual size SwiftUI assigned this
        // view at runtime — you need that here because "how wide is the
        // filled part" depends on how wide the WHOLE bar ends up being,
        // which you don't know until layout happens.
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.appSurface)
                Capsule()
                    .fill(Color.appPrimaryContainer)
                    .frame(width: geometry.size.width * progress)
            }
        }
        .frame(height: 8)
    }
}
