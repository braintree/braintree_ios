import SwiftUI

/// A left-to-right shimmer sweep, masked to the content's silhouette. Used for the
/// skeleton loading state (per the "Skeleton Shimmer" loader in the design).
struct ShimmerModifier: ViewModifier {

    @State private var animating = false

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, Color.white.opacity(0.65), .clear]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 0.6)
                    .offset(x: animating ? geo.size.width : -geo.size.width * 0.6)
                }
            )
            .mask(content)
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    animating = true
                }
            }
    }
}

extension View {

    /// Applies an animated shimmer sweep, masked to this view. Use on placeholder shapes.
    func shimmering() -> some View {
        modifier(ShimmerModifier())
    }
}

/// A rounded shimmer placeholder bar. Fills the available width minus `trailingGap`, so the
/// bar stops short of the trailing edge (matching the design) rather than running edge-to-edge.
struct ShimmerBar: View {

    var height: CGFloat = 22
    var cornerRadius: CGFloat = 11
    var trailingGap: CGFloat = 0

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color(.systemGray5))
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .padding(.trailing, trailingGap)
            .shimmering()
    }
}

/// Loading placeholder for the FI row: the real PayPal brand mark stays visible while a
/// shimmer bar fills the space where the FI pill will appear.
struct BTPayPalSavedPaymentMethodSkeletonRow: View {

    let style: BTPayPalSavedPaymentMethodViewStyle

    var body: some View {
        HStack(spacing: EditFiStyleGuard.fiClusterLeadingGap(style.container.fiCluster.leadingGap)) {
            PayPalBrandCluster(style: style)
            ShimmerBar(height: 16, cornerRadius: 4, trailingGap: 40)
        }
        .accessibilityElement()
        .accessibilityLabel("Loading saved payment method")
    }
}

/// Loading placeholder for the credit-messaging line: a shimmer bar that stops short of the edge.
struct CreditMessageSkeleton: View {

    var body: some View {
        ShimmerBar(height: 16, cornerRadius: 4, trailingGap: 40)
            .accessibilityHidden(true)
    }
}
