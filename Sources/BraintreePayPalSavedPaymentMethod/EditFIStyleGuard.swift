import SwiftUI
import UIKit

/// The SDK's built-in style defaults. Values for merchant-configurable fields apply when the merchant
/// leaves a field `nil`; the funding-instrument pill and card-icon values are fixed and are read
/// directly at the render site.
enum EditFIStyleDefaultConstants {

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
    static let fundingInstrumentTextColor = UIColor.black
    static let fundingInstrumentHorizontalPadding: CGFloat = 8
    static let fundingInstrumentVerticalPadding: CGFloat = 4

    static let cardIconCornerRadius: CGFloat = 3
    static let cardIconBorderColor = UIColor(white: 0.8, alpha: 1)
    static let cardIconBorderWidth: CGFloat = 0.71

    static let cardArtWidth: CGFloat = 28
    static let cardArtHeight: CGFloat = 20

    /// Gap between the card thumbnail and the masked number.
    static let fundingInstrumentViewGroupSpacing: CGFloat = 4
    /// Gap between that group and the edit pencil.
    static let fundingInstrumentViewEditSpacing: CGFloat = 8

    static let payPalLogoSide: CGFloat = 48

    /// Gap between the brand mark and the pill once they stack at large text sizes.
    static let stackedLayoutSpacing: CGFloat = 6

    static let creditMessageFontSize: CGFloat = 16
}

/// Resolves `PayPalSavedPaymentMethodViewStyle` values for rendering.
///
/// Two separate jobs, in order:
/// 1. **Default when absent** — a `nil` field means the merchant didn't set it, so the SDK default
///    from `EditFIStyleDefaultConstants` applies. `nil` never resolves to `0`.
/// 2. **Floor** — a merchant-supplied spacing or size is clamped to `[0, ∞)` with no upper cap, so
///    Dynamic Type scaling stays unbounded and accessibility is preserved.
///
/// Text sizes additionally fall back to `componentAppearance.baseFontSize` before the SDK default.
enum EditFIStyleGuard {

    // MARK: - Colors

    static func backgroundColor(_ value: UIColor?) -> UIColor {
        value ?? EditFIStyleDefaultConstants.backgroundColor
    }

    static func textColor(_ value: UIColor?) -> UIColor {
        value ?? EditFIStyleDefaultConstants.textColor
    }

    static func containerBorderColor(_ value: UIColor?) -> UIColor {
        value ?? EditFIStyleDefaultConstants.containerBorderColor
    }

    // MARK: - Text sizes

    /// Resolves a text size: the merchant's field, else `componentAppearance.baseFontSize`, else `defaultValue`.
    static func fontSize(_ value: CGFloat?, base: CGFloat?, default defaultValue: CGFloat) -> CGFloat {
        nonNegative(value ?? base ?? defaultValue)
    }

    // MARK: - Spacing and sizing

    /// Resolves a spacing or size: the merchant's field, else `defaultValue`.
    static func dimension(_ value: CGFloat?, default defaultValue: CGFloat) -> CGFloat {
        nonNegative(value ?? defaultValue)
    }

    /// `nil` preserves the container's intrinsic height, so it is passed through rather than defaulted.
    static func containerHeight(_ value: CGFloat?) -> CGFloat? {
        value.map(nonNegative)
    }

    // MARK: - Private Helpers

    private static func nonNegative(_ value: CGFloat) -> CGFloat {
        max(value, 0)
    }
}

extension PayPalSavedPaymentMethodViewStyle {

    /// The merchant's text color, else the SDK default.
    var resolvedTextColor: Color {
        Color(uiColor: EditFIStyleGuard.textColor(componentAppearance?.textColor))
    }
}
