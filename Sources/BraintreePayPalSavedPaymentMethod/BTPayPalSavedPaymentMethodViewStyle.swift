import UIKit

/// The styling contract for `BTPayPalSavedPaymentMethodView`.
///
/// Every field is optional: `nil` means "not set by the merchant", so the SDK applies its own
/// default for that element. `nil` never means zero — the defaults live in `EditFiStyleGuard`,
/// which also floors merchant-supplied spacing and sizes at `0`.
///
/// Text sizes resolve in three tiers: the element-specific size, then
/// `componentAppearance.baseFontSize`, then the SDK default for that element.
public struct BTPayPalSavedPaymentMethodViewStyle {

    /// Show the PayPal brand logo. Default: `true`.
    public var showPayPalLogo: Bool = true

    /// Show the "PayPal" text label. Default: `true`.
    public var showPayPalLabel: Bool = true

    /// Show the inline PayPal credit (Pay Later) messaging line. Default: `true`.
    public var showPayPalCreditMessaging: Bool = true

    /// Global type and color for the component. `nil` → SDK defaults.
    public var componentAppearance: ComponentAppearance?

    /// The outer container box and its positioned sub-views. `nil` → SDK defaults.
    public var container: ContainerStyle?

    public init() {}

    // MARK: - Nested style types

    /// Global type and color. Applies to the label, funding-instrument text, and credit messaging.
    public struct ComponentAppearance {

        /// Component background color. `nil` → SDK default (white).
        public var backgroundColor: UIColor?

        /// Base text color for the label, funding-instrument text, and credit messaging.
        /// `nil` → SDK default (≈ `#222222`).
        public var textColor: UIColor?

        /// Fallback text size for every element that doesn't set its own. `nil` → each element
        /// uses its own SDK default.
        public var baseFontSize: CGFloat?

        /// Registered custom-font PostScript name. `nil` → system font.
        public var fontName: String?

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

        /// Fixed height. `nil` → intrinsic / wrap content.
        public var height: CGFloat?

        /// Leading/trailing padding. `nil` → SDK default.
        public var horizontalPadding: CGFloat?

        /// Top/bottom padding. `nil` → SDK default.
        public var verticalPadding: CGFloat?

        /// Container corner radius. `nil` → SDK default.
        public var cornerRadius: CGFloat?

        /// Container border color. `nil` → SDK default (transparent, so no visible border).
        public var borderColor: UIColor?

        /// Container border width. `nil` → SDK default.
        public var borderWidth: CGFloat?

        /// The PayPal brand logo. `nil` → SDK defaults.
        public var logo: PayPalLogoStyle?

        /// The "PayPal" text label. `nil` → SDK defaults.
        public var label: PayPalLabelStyle?

        /// The funding-instrument cluster. `nil` → SDK defaults.
        public var fundingInstrument: FundingInstrumentStyle?

        /// The inline credit (Pay Later) messaging line. `nil` → SDK defaults.
        public var creditMessaging: CreditMessagingStyle?

        public init() {}
    }

    /// The PayPal brand logo.
    public struct PayPalLogoStyle {

        /// Side of the square (1:1) logo container. `nil` → SDK default. The logo artwork scales to
        /// fit inside, keeping its aspect ratio; growing this value grows both sides equally.
        public var width: CGFloat?

        public init() {}
    }

    /// The "PayPal" text label.
    public struct PayPalLabelStyle {

        /// Label text size. `nil` → `baseFontSize`, then the SDK default.
        public var fontSize: CGFloat?

        /// Gap between the logo and the label. `nil` → SDK default.
        public var leadingGap: CGFloat?

        public init() {}
    }

    /// The funding-instrument cluster: card art + last digits + edit pencil, inside a pill.
    ///
    /// The pill fill/shape/padding and the card-icon chrome are fixed to their Figma values and are
    /// not merchant-configurable.
    public struct FundingInstrumentStyle {

        /// Funding-instrument text size. `nil` → `baseFontSize`, then the SDK default.
        public var textFontSize: CGFloat?

        /// Edit (pencil) affordance size. `nil` → SDK default.
        public var editIconSize: CGFloat?

        /// Gap between the label cluster and the funding-instrument cluster. `nil` → SDK default.
        public var leadingGap: CGFloat?

        public init() {}
    }

    /// The inline credit (Pay Later) messaging line.
    public struct CreditMessagingStyle {

        /// Messaging text size. `nil` → `baseFontSize`, then the SDK default.
        public var fontSize: CGFloat?

        /// Accent color for the "Learn more" link. `nil` → the link is distinguished by bold +
        /// underline in the base text color instead.
        public var linkColor: UIColor?

        /// Internal placeholder copy for testing — not part of the public styling API. Replaced by
        /// the fetched offer copy when the messaging API is wired in.
        var messageText: String = "Or 4 interest-free payments of $324.50."

        /// Internal placeholder "Learn more" copy for testing — not part of the public styling API.
        var learnMoreText: String = "Learn more"

        public init() {}
    }
}
