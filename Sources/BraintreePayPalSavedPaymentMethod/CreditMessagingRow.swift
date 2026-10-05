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

    private var textColor: Color {
        Color(uiColor: EditFIStyleGuard.textColor(style.componentAppearance?.textColor))
    }

    /// Accent for "Learn more". When no `linkColor` is set, the link is distinguished by
    /// bold + underline in the base text color instead (styling doc §3.1).
    private var learnMoreColor: Color? {
        style.container?.creditMessaging?.linkColor.map { Color(uiColor: $0) }
    }

    private var font: Font {
        PayPalSavedPaymentMethodFont.font(
            size: EditFIStyleGuard.fontSize(
                style.container?.creditMessaging?.fontSize,
                base: style.componentAppearance?.baseFontSize,
                default: EditFIStyleDefaultConstants.creditMessageFontSize
            ),
            dynamicTypeSize: dynamicTypeSize,
            name: style.componentAppearance?.fontName
        )
    }

    var body: some View {
        Text(attributedMessage)
            .font(font)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            // The lander choice (embedded vs external) belongs to the view model, so the link's
            // URL is intercepted rather than opened by the system.
            .environment(\.openURL, OpenURLAction { _ in
                onLearnMore()
                return .handled
            })
    }

    /// "Learn more" is a link inside the message rather than a separate view, so it keeps flowing
    /// and wrapping inline while confining the tap to its own glyphs instead of the whole row.
    private var attributedMessage: AttributedString {
        var text = AttributedString(message)
        text.foregroundColor = textColor

        guard let learnMoreText, let url = learnMoreURL else {
            return text
        }

        var link = AttributedString(learnMoreText)
        link.link = url
        link.foregroundColor = learnMoreColor ?? textColor
        link.inlinePresentationIntent = .stronglyEmphasized

        // Without a merchant accent the link is distinguished by bold + underline (styling doc §3.1).
        if learnMoreColor == nil {
            link.underlineStyle = .single
        }

        return text + AttributedString(" ") + link
    }
}
