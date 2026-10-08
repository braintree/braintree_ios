import SwiftUI

/// A left-to-right shimmer sweep, masked to the content's silhouette. Used for the skeleton loading state.
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

/// A rounded shimmer placeholder bar that fills the available width and stops short of the trailing edge.
struct ShimmerBar: View {

    var body: some View {
        RoundedRectangle(cornerRadius: EditFIStyleDefaultConstants.shimmerBarCornerRadius)
            .fill(Color(.systemGray5))
            .frame(height: EditFIStyleDefaultConstants.shimmerBarHeight)
            .frame(maxWidth: .infinity)
            .padding(.trailing, EditFIStyleDefaultConstants.shimmerBarTrailingGap)
            .shimmering()
    }
}

/// Loading placeholder for the FI row: the real PayPal brand mark stays visible while a
/// shimmer bar fills the space where the FI pill will appear.
struct PayPalSavedPaymentMethodSkeletonRow: View {

    let style: PayPalSavedPaymentMethodViewStyle

    var body: some View {
        HStack(spacing: EditFIStyleGuard.dimension(
            style.container?.fundingInstrument?.leadingGap,
            default: EditFIStyleDefaultConstants.fundingInstrumentLeadingGap
        )) {
            PayPalBrandCluster(style: style)
            ShimmerBar()
        }
        .accessibilityElement()
        .accessibilityLabel("Loading saved payment method")
    }
}

/// Loading placeholder for the credit-messaging line: a shimmer bar that stops short of the edge.
struct CreditMessageSkeleton: View {

    var body: some View {
        ShimmerBar()
            .accessibilityHidden(true)
    }
}
