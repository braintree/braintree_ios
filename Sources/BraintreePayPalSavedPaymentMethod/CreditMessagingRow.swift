import SwiftUI
import UIKit

/// The inline credit (Pay Later) messaging line rendered below the FI row.
///
/// The copy comes from the fetched `BTPayPalCreditMessagingResult` (composed into
/// `CreditMessageContent`). Tapping "Learn more" presents the lander (`click_url` webview).
struct CreditMessagingRow: View {

    let style: BTPayPalSavedPaymentMethodViewStyle
    let content: CreditMessageContent
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
        BTPayPalSavedPaymentMethodFont.font(
            name: style.componentAppearance?.fontName,
            size: EditFIStyleGuard.fontSize(
                style.container?.creditMessaging?.fontSize,
                base: style.componentAppearance?.baseFontSize,
                default: EditFIStyleGuard.Defaults.creditMessageFontSize
            ),
            dynamicTypeSize: dynamicTypeSize
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
        var message = AttributedString(content.message)
        message.foregroundColor = textColor

        guard let learnMoreText = content.learnMoreText, let url = content.learnMoreURL else {
            return message
        }

        var link = AttributedString(learnMoreText)
        link.link = url
        link.foregroundColor = learnMoreColor ?? textColor
        link.inlinePresentationIntent = .stronglyEmphasized

        // Without a merchant accent the link is distinguished by bold + underline (styling doc §3.1).
        if learnMoreColor == nil {
            link.underlineStyle = .single
        }

        return message + AttributedString(" ") + link
    }
}
