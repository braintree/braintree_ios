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

    private var textColor: Color {
        Color(uiColor: EditFiStyleGuard.textColor(style.componentAppearance?.textColor))
    }

    /// Accent for "Learn more". When no `linkColor` is set, the link is distinguished by
    /// bold + underline in the base text color instead (styling doc §3.1).
    private var learnMoreColor: Color? {
        style.container?.creditMessaging?.linkColor.map { Color(uiColor: $0) }
    }

    private var font: Font {
        BTPayPalSavedPaymentMethodFont.font(
            name: style.componentAppearance?.fontName,
            size: EditFiStyleGuard.creditMessageFontSize(
                style.container?.creditMessaging?.fontSize,
                base: style.componentAppearance?.baseFontSize
            )
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

/// The display-ready credit message composed from a fetched `BTPayPalCreditMessagingResult`.
struct CreditMessageContent: Equatable {

    /// The non-tappable copy: main block plus any disclaimer block, space-joined.
    let message: String

    /// The "Learn more" action copy, when present.
    let learnMoreText: String?

    /// The URL opened when "Learn more" is tapped.
    let learnMoreURL: URL?

    /// Whether `learnMoreURL` may load in an embedded web view rather than an external browser.
    let isEmbeddable: Bool

    /// Seeds content directly. Used by SwiftUI previews and tests, which have no network response.
    init(message: String, learnMoreText: String?, learnMoreURL: URL?, isEmbeddable: Bool) {
        self.message = message
        self.learnMoreText = learnMoreText
        self.learnMoreURL = learnMoreURL
        self.isEmbeddable = isEmbeddable
    }

    /// Composes the content, or returns `nil` when there is no main copy to display (hide the row).
    init?(result: BTPayPalCreditMessagingResult) {
        let mainText = Self.compose(result.mainItems)
        guard !mainText.isEmpty else { return nil }

        // Order per PayPal: main, then disclaimers (empty today, may be enabled later), then action.
        let disclaimerText = Self.compose(result.disclaimerItems)
        self.message = [mainText, disclaimerText].filter { !$0.isEmpty }.joined(separator: " ")

        let actionText = Self.compose(result.actionItems)
        let action = result.actionItems.first { $0.clickURL != nil } ?? result.actionItems.first

        // Without a click URL the link would render but do nothing, so the copy is dropped with it.
        self.learnMoreURL = action?.clickURL
        self.learnMoreText = (actionText.isEmpty || action?.clickURL == nil) ? nil : actionText
        self.isEmbeddable = action?.isEmbeddable ?? false
    }

    /// Resolves each block to its display text — `image` blocks use their `alternativeText`
    /// (e.g. the "PayPal" logo renders as the word "PayPal") — and concatenates them in order
    /// with no separator, since each block already carries its own surrounding whitespace.
    private static func compose(_ items: [BTPayPalCreditMessageItem]) -> String {
        items.map { item in
            switch item.type {
            case .image:
                return item.alternativeText ?? item.text ?? ""
            default:
                return item.text ?? item.alternativeText ?? ""
            }
        }
        .joined()
    }
}
