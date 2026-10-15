import SwiftUI
import UIKit

/// The inline credit (Pay Later) messaging line rendered below the FI row.
///
/// Tapping "Learn more" hands the tap back through `onLearnMore` so the caller picks how the lander opens.
struct CreditMessagingRow: View {

    let style: PayPalSavedPaymentMethodViewStyle
    let message: String
    let learnMoreText: String?
    let learnMoreURL: URL?
    let onLearnMore: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // MARK: - Private Properties

    /// Accent for "Learn more". When no `linkColor` is set, the link is distinguished by
    /// an underline in the base text color instead.
    private var learnMoreColor: Color? {
        style.container?.creditMessaging?.linkColor.map { Color(uiColor: $0) }
    }

    private var fontSize: CGFloat {
        EditFIStyleGuard.fontSize(
            style.container?.creditMessaging?.fontSize,
            base: style.componentAppearance?.baseFontSize,
            default: EditFIStyleDefaultConstants.creditMessageFontSize
        )
    }

    // MARK: - Body

    var body: some View {
        Text(attributedMessage)
            .font(font(weight: .regular))
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            // The lander choice (embedded vs external) belongs to the view model, so the link's
            // URL is intercepted rather than opened by the system.
            .environment(\.openURL, OpenURLAction { _ in
                onLearnMore()
                return .handled
            })
    }

    // MARK: - Internal Properties

    /// "Learn more" is a link inside the message rather than a separate view, so it keeps flowing
    /// and wrapping inline while confining the tap to its own glyphs instead of the whole row.
    /// Internal for testing.
    var attributedMessage: AttributedString {
        var text = AttributedString(message)
        text.foregroundColor = style.resolvedTextColor

        guard let learnMoreText, let url = learnMoreURL else {
            return text
        }

        var link = AttributedString(learnMoreText)
        link.link = url
        link.foregroundColor = learnMoreColor ?? style.resolvedTextColor
        link.font = font(weight: .medium)

        // Without a merchant accent the link is distinguished by an underline.
        if learnMoreColor == nil {
            link.underlineStyle = .single
        }

        return text + AttributedString(" ") + link
    }

    // MARK: - Private Methods

    private func font(weight: Font.Weight) -> Font {
        PayPalSavedPaymentMethodFont.font(
            size: fontSize,
            dynamicTypeSize: dynamicTypeSize,
            name: style.componentAppearance?.fontName,
            weight: weight
        )
    }
}
