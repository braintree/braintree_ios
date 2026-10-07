import UIKit

/// The styling contract for `PayPalSavedPaymentMethodView`.
///
/// Every field is optional: `nil` means "not set by the merchant", so the SDK applies its own
/// default for that element. `nil` never means zero — the defaults live in `EditFIStyleGuard`,
/// which also floors merchant-supplied spacing and sizes at `0`.
///
/// Text sizes resolve in three tiers: the element-specific size, then
/// `componentAppearance.baseFontSize`, then the SDK default for that element.
/// - Warning: This feature is in beta. It's public API may change or be removed in future releases.
public struct PayPalSavedPaymentMethodViewStyle {

    // MARK: - Internal Properties

    let showPayPalLogo: Bool
    let showPayPalLabel: Bool
    let showPayPalCreditMessaging: Bool
    let componentAppearance: ComponentAppearance?
    let container: ContainerStyle?

    // MARK: - Initializer

    /// Creates a `PayPalSavedPaymentMethodViewStyle`.
    /// - Parameters:
    ///   - showPayPalLogo: Optional. Show the PayPal brand logo. Defaults to `true`.
    ///   - showPayPalLabel: Optional. Show the "PayPal" text label. Defaults to `true`.
    ///   - showPayPalCreditMessaging: Optional. Show the inline PayPal credit (Pay Later) messaging line.
    ///     Defaults to `true`.
    ///   - componentAppearance: Optional. Global type and color for the component. `nil` → SDK defaults.
    ///   - container: Optional. The outer container box and its positioned sub-views. `nil` → SDK defaults.
    public init(
        showPayPalLogo: Bool = true,
        showPayPalLabel: Bool = true,
        showPayPalCreditMessaging: Bool = true,
        componentAppearance: ComponentAppearance? = nil,
        container: ContainerStyle? = nil
    ) {
        self.showPayPalLogo = showPayPalLogo
        self.showPayPalLabel = showPayPalLabel
        self.showPayPalCreditMessaging = showPayPalCreditMessaging
        self.componentAppearance = componentAppearance
        self.container = container
    }

    // MARK: - Nested style types

    /// Global type and color. Applies to the label, funding-instrument text, and credit messaging.
    public struct ComponentAppearance {

        let backgroundColor: UIColor?
        let textColor: UIColor?
        let baseFontSize: CGFloat?
        let fontName: String?

        /// Creates a `ComponentAppearance`.
        /// - Parameters:
        ///   - backgroundColor: Optional. Component background color. `nil` → SDK default (white).
        ///   - textColor: Optional. Base text color for the label and credit messaging. The funding-instrument
        ///     pill keeps a fixed color so it stays legible on its fixed background. `nil` → SDK default (≈ `#222222`).
        ///   - baseFontSize: Optional. Fallback text size for every element that doesn't set its own.
        ///     `nil` → each element uses its own SDK default.
        ///   - fontName: Optional. Registered custom-font PostScript name. `nil` → system font.
        public init(
            backgroundColor: UIColor? = nil,
            textColor: UIColor? = nil,
            baseFontSize: CGFloat? = nil,
            fontName: String? = nil
        ) {
            self.backgroundColor = backgroundColor
            self.textColor = textColor
            self.baseFontSize = baseFontSize
            self.fontName = fontName
        }
    }

    /// The outer container box plus its positioned sub-views.
    public struct ContainerStyle {

        let height: CGFloat?
        let horizontalPadding: CGFloat?
        let verticalPadding: CGFloat?
        let cornerRadius: CGFloat?
        let borderColor: UIColor?
        let borderWidth: CGFloat?
        let logo: PayPalLogoStyle?
        let label: PayPalLabelStyle?
        let fundingInstrument: FundingInstrumentStyle?
        let creditMessaging: CreditMessagingStyle?

        /// Creates a `ContainerStyle`.
        /// - Parameters:
        ///   - height: Optional. Fixed height. `nil` → intrinsic / wrap content.
        ///   - horizontalPadding: Optional. Leading/trailing padding. `nil` → SDK default.
        ///   - verticalPadding: Optional. Top/bottom padding. `nil` → SDK default.
        ///   - cornerRadius: Optional. Container corner radius. `nil` → SDK default.
        ///   - borderColor: Optional. Container border color. `nil` → SDK default (transparent, so no visible border).
        ///   - borderWidth: Optional. Container border width. `nil` → SDK default.
        ///   - logo: Optional. The PayPal brand logo. `nil` → SDK defaults.
        ///   - label: Optional. The "PayPal" text label. `nil` → SDK defaults.
        ///   - fundingInstrument: Optional. The funding-instrument cluster. `nil` → SDK defaults.
        ///   - creditMessaging: Optional. The inline credit (Pay Later) messaging line. `nil` → SDK defaults.
        public init(
            height: CGFloat? = nil,
            horizontalPadding: CGFloat? = nil,
            verticalPadding: CGFloat? = nil,
            cornerRadius: CGFloat? = nil,
            borderColor: UIColor? = nil,
            borderWidth: CGFloat? = nil,
            logo: PayPalLogoStyle? = nil,
            label: PayPalLabelStyle? = nil,
            fundingInstrument: FundingInstrumentStyle? = nil,
            creditMessaging: CreditMessagingStyle? = nil
        ) {
            self.height = height
            self.horizontalPadding = horizontalPadding
            self.verticalPadding = verticalPadding
            self.cornerRadius = cornerRadius
            self.borderColor = borderColor
            self.borderWidth = borderWidth
            self.logo = logo
            self.label = label
            self.fundingInstrument = fundingInstrument
            self.creditMessaging = creditMessaging
        }
    }

    /// The PayPal brand logo.
    public struct PayPalLogoStyle {

        let width: CGFloat?

        /// Creates a `PayPalLogoStyle`.
        /// - Parameter width: Optional. Side of the square (1:1) logo container. `nil` → SDK default. The logo
        ///   artwork scales to fit inside, keeping its aspect ratio; growing this value grows both sides equally.
        public init(width: CGFloat? = nil) {
            self.width = width
        }
    }

    /// The "PayPal" text label.
    public struct PayPalLabelStyle {

        let fontSize: CGFloat?
        let leadingGap: CGFloat?

        /// Creates a `PayPalLabelStyle`.
        /// - Parameters:
        ///   - fontSize: Optional. Label text size. `nil` → `baseFontSize`, then the SDK default.
        ///   - leadingGap: Optional. Gap between the logo and the label. `nil` → SDK default.
        public init(fontSize: CGFloat? = nil, leadingGap: CGFloat? = nil) {
            self.fontSize = fontSize
            self.leadingGap = leadingGap
        }
    }

    /// The funding-instrument cluster: card art + last digits + edit pencil, inside a pill.
    ///
    /// The pill fill/shape/padding and the card-icon chrome are fixed and are not merchant-configurable.
    public struct FundingInstrumentStyle {

        let textFontSize: CGFloat?
        let editIconSize: CGFloat?
        let leadingGap: CGFloat?

        /// Creates a `FundingInstrumentStyle`.
        /// - Parameters:
        ///   - textFontSize: Optional. Funding-instrument text size. `nil` → `baseFontSize`, then the SDK default.
        ///   - editIconSize: Optional. Edit (pencil) affordance size. `nil` → SDK default.
        ///   - leadingGap: Optional. Gap between the label cluster and the funding-instrument cluster.
        ///     `nil` → SDK default.
        public init(
            textFontSize: CGFloat? = nil,
            editIconSize: CGFloat? = nil,
            leadingGap: CGFloat? = nil
        ) {
            self.textFontSize = textFontSize
            self.editIconSize = editIconSize
            self.leadingGap = leadingGap
        }
    }

    /// The inline credit (Pay Later) messaging line.
    public struct CreditMessagingStyle {

        let fontSize: CGFloat?
        let linkColor: UIColor?

        /// Creates a `CreditMessagingStyle`.
        /// - Parameters:
        ///   - fontSize: Optional. Messaging text size. `nil` → `baseFontSize`, then the SDK default.
        ///   - linkColor: Optional. Accent color for the "Learn more" link. `nil` → the link is distinguished by
        ///     bold + underline in the base text color instead.
        public init(fontSize: CGFloat? = nil, linkColor: UIColor? = nil) {
            self.fontSize = fontSize
            self.linkColor = linkColor
        }
    }
}
