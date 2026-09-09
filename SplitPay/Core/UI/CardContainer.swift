import SwiftUI


struct CardContainer<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            content
        }
        .padding(Theme.Spacing.cardPadding)
        .glassEffect(.regular, in: Theme.Shape.card)
    }
}

struct GlassCardStack<Content: View>: View {
    private let spacing: CGFloat
    private let content: Content

    init(spacing: CGFloat = Theme.Spacing.sectionSpacing, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        GlassEffectContainer(spacing: spacing) {
            VStack(spacing: spacing) {
                content
            }
        }
    }
}
