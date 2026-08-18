import UIKit

/// Resolves `BTPayPalSavedPaymentMethodViewStyle` values for rendering.
///
/// Two separate jobs, in order:
/// 1. **Default when absent** — a `nil` field means the merchant didn't set it, so the SDK default
///    below applies. `nil` never resolves to `0`.
/// 2. **Floor** — a merchant-supplied spacing or size is clamped to `[0, ∞)` with no upper cap, so
///    Dynamic Type scaling stays unbounded and accessibility is preserved.
///
/// Text sizes additionally fall back to `componentAppearance.baseFontSize` before the SDK default.
enum EditFiStyleGuard {

    /// The SDK's built-in defaults. Values for merchant-configurable fields apply when the merchant
    /// leaves a field `nil`; the funding-instrument pill and card-icon values are fixed and are read
    /// directly at the render site.
    enum Defaults {
        static let backgroundColor = UIColor.white
        static let textColor = UIColor(white: 0.133, alpha: 1)

        static let containerHorizontalPadding: CGFloat = 0
        static let containerVerticalPadding: CGFloat = 10
        static let containerCornerRadius: CGFloat = 0
        static let containerBorderColor = UIColor.clear
        static let containerBorderWidth: CGFloat = 0

        static let labelFontSize: CGFloat = 20
        static let labelLeadingGap: CGFloat = 12.73

        static let fundingInstrumentTextFontSize: CGFloat = 14
        static let editIconSize: CGFloat = 16
        static let fundingInstrumentLeadingGap: CGFloat = 8
        static let fundingInstrumentBackgroundColor = UIColor(
            red: 240 / 255,
            green: 242 / 255,
            blue: 249 / 255,
            alpha: 1
        )
        static let fundingInstrumentCornerRadius: CGFloat = 6
        static let fundingInstrumentHorizontalPadding: CGFloat = 8
        static let fundingInstrumentVerticalPadding: CGFloat = 4

        static let cardIconCornerRadius: CGFloat = 3
        static let cardIconBorderColor = UIColor(white: 0.8, alpha: 1)
        static let cardIconBorderWidth: CGFloat = 0.71

        static let creditMessageFontSize: CGFloat = 16
    }

    // MARK: - Colors

    static func backgroundColor(_ value: UIColor?) -> UIColor {
        value ?? Defaults.backgroundColor
    }

    static func textColor(_ value: UIColor?) -> UIColor {
        value ?? Defaults.textColor
    }

    static func containerBorderColor(_ value: UIColor?) -> UIColor {
        value ?? Defaults.containerBorderColor
    }

    // MARK: - Text sizes

    static func labelFontSize(_ value: CGFloat?, base: CGFloat?) -> CGFloat {
        nonNegative(value ?? base ?? Defaults.labelFontSize)
    }

    static func fundingInstrumentTextFontSize(_ value: CGFloat?, base: CGFloat?) -> CGFloat {
        nonNegative(value ?? base ?? Defaults.fundingInstrumentTextFontSize)
    }

    static func creditMessageFontSize(_ value: CGFloat?, base: CGFloat?) -> CGFloat {
        nonNegative(value ?? base ?? Defaults.creditMessageFontSize)
    }

    // MARK: - Spacing and sizing

    static func labelLeadingGap(_ value: CGFloat?) -> CGFloat {
        nonNegative(value ?? Defaults.labelLeadingGap)
    }

    static func fundingInstrumentLeadingGap(_ value: CGFloat?) -> CGFloat {
        nonNegative(value ?? Defaults.fundingInstrumentLeadingGap)
    }

    static func editIconSize(_ value: CGFloat?) -> CGFloat {
        nonNegative(value ?? Defaults.editIconSize)
    }

    /// Logo width has no SDK-default constant here: callers fall back to the brand cluster's own
    /// intrinsic size when the merchant leaves it unset.
    static func logoWidth(_ value: CGFloat) -> CGFloat {
        nonNegative(value)
    }

    static func horizontalPadding(_ value: CGFloat?) -> CGFloat {
        nonNegative(value ?? Defaults.containerHorizontalPadding)
    }

    static func verticalPadding(_ value: CGFloat?) -> CGFloat {
        nonNegative(value ?? Defaults.containerVerticalPadding)
    }

    static func cornerRadius(_ value: CGFloat?) -> CGFloat {
        nonNegative(value ?? Defaults.containerCornerRadius)
    }

    static func borderWidth(_ value: CGFloat?) -> CGFloat {
        nonNegative(value ?? Defaults.containerBorderWidth)
    }

    // MARK: - Private Helpers

    private static func nonNegative(_ value: CGFloat) -> CGFloat {
        max(value, 0)
    }
}
