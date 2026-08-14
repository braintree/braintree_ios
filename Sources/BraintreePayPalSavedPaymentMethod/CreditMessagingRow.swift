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
        Color(uiColor: style.theme.textColorBase ?? UIColor(white: 0.133, alpha: 1))
    }

    /// Accent for "Learn more". When no `linkColor` is set, the link is distinguished by
    /// bold + underline in the base text color instead (styling doc §3.1).
    private var learnMoreColor: Color? {
        style.theme.linkColor.map { Color(uiColor: $0) }
    }

    private var font: Font {
        BTPayPalSavedPaymentMethodFont.font(
            name: style.theme.fontName,
            size: EditFiStyleGuard.creditMessageFontSize(style.container.creditMessaging.fontSize)
        )
    }

    var body: some View {
        // "Learn more" flows inline right after the message and wraps with it (matching design).
        let message = Text(content.message + (content.learnMoreText != nil ? " " : ""))
            .foregroundColor(textColor)
        let learnMore = content.learnMoreText.map { text in
            Text(text)
                .fontWeight(.semibold)
                .underline(learnMoreColor == nil)
                .foregroundColor(learnMoreColor ?? textColor)
        } ?? Text("")

        return (message + learnMore)
            .font(font)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture { onLearnMore() }
            .accessibilityElement()
            .accessibilityLabel([content.message, content.learnMoreText].compactMap { $0 }.joined(separator: " "))
            .accessibilityAddTraits(.isButton)
            .accessibilityHint("Opens Pay Later details")
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

    /// Composes the content, or returns `nil` when there is no main copy to display (hide the row).
    init?(result: BTPayPalCreditMessagingResult) {
        let mainText = Self.compose(result.mainItems)
        guard !mainText.isEmpty else { return nil }

        // Order per PayPal: main, then disclaimers (empty today, may be enabled later), then action.
        let disclaimerText = Self.compose(result.disclaimerItems)
        self.message = [mainText, disclaimerText].filter { !$0.isEmpty }.joined(separator: " ")

        let actionText = Self.compose(result.actionItems)
        self.learnMoreText = actionText.isEmpty ? nil : actionText

        let action = result.actionItems.first { $0.clickURL != nil } ?? result.actionItems.first
        self.learnMoreURL = action?.clickURL
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
