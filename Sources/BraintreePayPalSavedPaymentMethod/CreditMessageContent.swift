import Foundation

/// The display-ready credit message composed from a fetched `PayPalCreditMessagingResult`.
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
    init?(result: PayPalCreditMessagingResult) {
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
    private static func compose(_ items: [PayPalCreditMessageItem]) -> String {
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
