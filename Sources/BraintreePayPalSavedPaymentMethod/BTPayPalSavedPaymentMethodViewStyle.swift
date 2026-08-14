import UIKit

/// The styling contract for `BTPayPalSavedPaymentMethodView`.
///
/// Modeled as the view hierarchy itself (mobile-native, matching the Android
/// `SavedPaymentMethodViewStyle` tree): top-level visibility toggles, a `theme` group for
/// global type & color, and a `container` group that owns the box shape plus each
/// positioned sub-view (`logo`, `label`, `fiCluster`, `creditMessaging`).
///
/// Field set, defaults, and guards match Android; only the types differ (`dp`/`sp` →
/// `CGFloat` points, with text sizes rendered through Dynamic Type; `@ColorInt` →
/// `UIColor`; `@FontRes` → `fontName` PostScript string). Merchant-supplied values are
/// clamped by `EditFiStyleGuard` at render time.
public struct BTPayPalSavedPaymentMethodViewStyle {

    /// Show the PayPal brand logo. Default: `true`.
    public var showLogo: Bool = true

    /// Show the "PayPal" text label. Default: `true`.
    public var showLabel: Bool = true

    /// Show the inline credit (Pay Later) messaging line. Default: `true`.
    /// (Only rendered when the request also sets `showCreditMessage`.)
    public var showCreditMessaging: Bool = true

    public var theme: Theme = Theme()
    public var container: Container = Container()

    public init() {}

    // MARK: - Nested style types

    /// Global type & color. Applies to the label, FI text, and credit messaging.
    public struct Theme {

        /// Component background color. Default: white.
        public var backgroundColor: UIColor? = .white

        /// Base text color for label, FI text, and credit messaging. Default: ≈ `#222222`.
        public var textColorBase: UIColor? = UIColor(white: 0.133, alpha: 1)

        /// Accent color for the credit-messaging "Learn more" link. When `nil`, the link is
        /// distinguished by bold + underline in the base text color instead.
        public var linkColor: UIColor?

        /// Registered custom-font PostScript name. `nil` → system font. Mirrors Android `@FontRes`.
        public var fontName: String?

        public init() {}
    }

    /// The outer container box plus its positioned sub-views.
    public struct Container {

        /// Fixed height. `nil` → intrinsic / wrap content (default).
        public var height: CGFloat?

        /// Leading/trailing padding. Default: 0.
        public var horizontalPadding: CGFloat = 0

        /// Top/bottom padding. Default: 10.
        public var verticalPadding: CGFloat = 10

        /// Container corner radius. Default: 0.
        public var cornerRadius: CGFloat = 0

        /// Container border color. Default: transparent (no visible border).
        public var borderColor: UIColor? = .clear

        /// Container border width. Default: 0.
        public var borderWidth: CGFloat = 0

        public var logo: Logo = Logo()
        public var label: Label = Label()
        public var fiCluster: FiCluster = FiCluster()
        public var creditMessaging: CreditMessaging = CreditMessaging()

        public init() {}
    }

    /// The PayPal brand logo.
    public struct Logo {

        /// Side of the square (1:1) logo container. `nil` → 48×48 default. The 48×30 logo artwork
        /// scales to fit inside, keeping its aspect ratio; growing this value grows both sides equally.
        public var width: CGFloat?

        public init() {}
    }

    /// The "PayPal" text label.
    public struct Label {

        /// Label text size. Default: 20 pt · Dynamic Type (floor 0).
        public var fontSize: CGFloat = 20

        /// Gap between the logo and the label. Default: 12.73 (floor 0).
        public var leadingGap: CGFloat = 12.73

        public init() {}
    }

    /// The funding-instrument cluster: card art + last digits + edit pencil, inside a pill.
    public struct FiCluster {

        /// FI text size. Default: 14 pt · Dynamic Type (floor 0).
        public var textFontSize: CGFloat = 14

        /// Edit (pencil) affordance size. Default: 16 pt (floor 0).
        public var editIconSize: CGFloat = 16

        /// Gap between the label cluster and the FI cluster. Default: 8 (floor 0).
        public var leadingGap: CGFloat = 8

        /// Background color of the FI pill. `nil` → no pill. Default: `#F0F2F9`.
        public var backgroundColor: UIColor? = UIColor(red: 240 / 255, green: 242 / 255, blue: 249 / 255, alpha: 1)

        /// FI pill corner radius. Default: 6 (floor 0).
        public var cornerRadius: CGFloat = 6

        /// FI pill horizontal (leading/trailing) padding. Default: 8 (floor 0).
        public var horizontalPadding: CGFloat = 8

        /// FI pill vertical (top/bottom) padding. Default: 4 (floor 0).
        public var verticalPadding: CGFloat = 4

        /// Optional background color behind the FI card art icon. `nil` → none.
        public var cardIconBackgroundColor: UIColor?

        /// Corner radius for the FI card art icon. Default: 3 (floor 0).
        public var cardIconCornerRadius: CGFloat = 3

        /// Border color for the FI card art icon. `nil` → no border. Default: `#CCCCCC`.
        public var cardIconBorderColor: UIColor? = UIColor(white: 0.8, alpha: 1)

        /// Border width for the FI card art icon. Default: 0.71 pt hairline (floor 0).
        public var cardIconBorderWidth: CGFloat = 0.71

        public init() {}
    }

    /// The inline credit (Pay Later) messaging line.
    public struct CreditMessaging {

        /// Messaging text size. Default: 16 pt · Dynamic Type (floor 0).
        public var fontSize: CGFloat = 16

        /// Internal placeholder copy for testing — not part of the public styling API. Replaced by
        /// the fetched offer copy when the messaging API is wired in.
        var messageText: String = "Or 4 interest-free payments of $324.50."

        /// Internal placeholder "Learn more" copy for testing — not part of the public styling API.
        var learnMoreText: String = "Learn more"

        public init() {}
    }
}
