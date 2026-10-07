import SwiftUI

/// The PayPal brand mark: `[badge] PayPal`. Shared by the loaded row and the loading skeleton
/// so the brand stays visible while the FI loads.
struct PayPalBrandCluster: View {

    let style: PayPalSavedPaymentMethodViewStyle

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // MARK: - Private Properties

    private var labelFont: Font {
        PayPalSavedPaymentMethodFont.font(
            size: EditFIStyleGuard.fontSize(
                style.container?.label?.fontSize,
                base: style.componentAppearance?.baseFontSize,
                default: EditFIStyleDefaultConstants.labelFontSize
            ),
            dynamicTypeSize: dynamicTypeSize,
            name: style.componentAppearance?.fontName,
            weight: .bold
        )
    }

    /// The PayPal logo (48×30 artwork) sits in a square (1:1) container. `logo.width` sets the
    /// side (default 48); the artwork scales to fit inside, preserving its own aspect ratio.
    private var logoSide: CGFloat {
        EditFIStyleGuard.dimension(style.container?.logo?.width, default: EditFIStyleDefaultConstants.payPalLogoSide)
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: EditFIStyleGuard.dimension(
            style.container?.label?.leadingGap,
            default: EditFIStyleDefaultConstants.labelLeadingGap
        )) {
            if style.showPayPalLogo {
                Image("PayPalBadge", bundle: .payPalSavedPaymentMethod)
                    .resizable()
                    .scaledToFit()
                    .frame(width: logoSide, height: logoSide)
                    .accessibilityHidden(true)
            }
            if style.showPayPalLabel {
                Text("PayPal")
                    .font(labelFont)
                    .foregroundColor(style.resolvedTextColor)
                    .fixedSize()
            }
        }
    }
}
