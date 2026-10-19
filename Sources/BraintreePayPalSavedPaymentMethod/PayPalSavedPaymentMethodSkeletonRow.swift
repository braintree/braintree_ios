import SwiftUI

/// A left-to-right shimmer sweep, masked to the content's silhouette. Used for the skeleton loading state.
struct ShimmerModifier: ViewModifier {

    @State private var animating = false

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    let highlightWidth = geo.size.width * EditFIStyleDefaultConstants.shimmerHighlightWidthRatio
                    LinearGradient(
                        gradient: Gradient(
                            colors: [.clear, Color.white.opacity(EditFIStyleDefaultConstants.shimmerHighlightOpacity), .clear]
                        ),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: highlightWidth)
                    .offset(x: animating ? geo.size.width : -highlightWidth)
                }
            )
            .mask(content)
            .onAppear {
                withAnimation(.linear(duration: EditFIStyleDefaultConstants.shimmerDuration).repeatForever(autoreverses: false)) {
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
            .fill(Color(uiColor: EditFIStyleDefaultConstants.shimmerBarColor))
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

    private var fundingInstrumentGap: CGFloat {
        EditFIStyleGuard.dimension(
            style.container?.fundingInstrument?.leadingGap,
            default: EditFIStyleDefaultConstants.fundingInstrumentLeadingGap
        )
    }

    var body: some View {
        HStack(spacing: 0) {
            // A hidden brand mark would still take the gap, so it is left out entirely.
            if style.showPayPalLogo || style.showPayPalLabel {
                PayPalBrandCluster(style: style)
                    .padding(.trailing, fundingInstrumentGap)
            }
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
