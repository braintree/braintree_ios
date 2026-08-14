import CoreGraphics

/// Platform-agnostic guardrails for `BTPayPalSavedPaymentMethodViewStyle` (styling doc §4).
///
/// Per the approved styling doc, every spacing/sizing/font-size field floors at `0`
/// (never negative) with **no upper cap** — merchants have full discretion above the
/// floor. Dynamic Type scaling on top of a font size is left unbounded so accessibility
/// is preserved.
enum EditFiStyleGuard {

    /// Gap between the logo and the label: `[0, ∞)`.
    static func labelLeadingGap(_ value: CGFloat) -> CGFloat {
        nonNegative(value)
    }

    /// Gap between the label and FI clusters: `[0, ∞)`.
    static func fiClusterLeadingGap(_ value: CGFloat) -> CGFloat {
        nonNegative(value)
    }

    /// Label text size: `[0, ∞)`.
    static func labelFontSize(_ value: CGFloat) -> CGFloat {
        nonNegative(value)
    }

    /// FI text size: `[0, ∞)`.
    static func fiTextFontSize(_ value: CGFloat) -> CGFloat {
        nonNegative(value)
    }

    /// Edit-icon size: `[0, ∞)`.
    static func editIconSize(_ value: CGFloat) -> CGFloat {
        nonNegative(value)
    }

    /// FI pill corner radius: `[0, ∞)`.
    static func fiClusterCornerRadius(_ value: CGFloat) -> CGFloat {
        nonNegative(value)
    }

    /// FI pill horizontal padding: `[0, ∞)`.
    static func fiClusterHorizontalPadding(_ value: CGFloat) -> CGFloat {
        nonNegative(value)
    }

    /// FI pill vertical padding: `[0, ∞)`.
    static func fiClusterVerticalPadding(_ value: CGFloat) -> CGFloat {
        nonNegative(value)
    }

    /// FI card-art corner radius: `[0, ∞)`.
    static func cardIconCornerRadius(_ value: CGFloat) -> CGFloat {
        nonNegative(value)
    }

    /// FI card-art border width: `[0, ∞)`.
    static func cardIconBorderWidth(_ value: CGFloat) -> CGFloat {
        nonNegative(value)
    }

    /// Logo width: `[0, ∞)`.
    static func logoWidth(_ value: CGFloat) -> CGFloat {
        nonNegative(value)
    }

    /// Credit-messaging text size: `[0, ∞)`.
    static func creditMessageFontSize(_ value: CGFloat) -> CGFloat {
        nonNegative(value)
    }

    /// Container horizontal padding: `[0, ∞)`.
    static func horizontalPadding(_ value: CGFloat) -> CGFloat {
        nonNegative(value)
    }

    /// Container vertical padding: `[0, ∞)`.
    static func verticalPadding(_ value: CGFloat) -> CGFloat {
        nonNegative(value)
    }

    /// Container corner radius: `[0, ∞)`.
    static func cornerRadius(_ value: CGFloat) -> CGFloat {
        nonNegative(value)
    }

    /// Container border width: `[0, ∞)`.
    static func borderWidth(_ value: CGFloat) -> CGFloat {
        nonNegative(value)
    }

    // MARK: - Private Helpers

    private static func nonNegative(_ value: CGFloat) -> CGFloat {
        max(value, 0)
    }
}
