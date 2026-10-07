import Foundation

/// The display-ready credit message composed from a fetched `PayPalCreditMessagingResult`.
struct CreditMessageContent: Equatable {

    /// The tappable "Learn more" link.
    struct LearnMore: Equatable {

        /// The link copy.
        let text: String

        /// The lander opened when the link is tapped.
        let url: URL

        /// Whether `url` may load in an embedded web view rather than an external browser.
        let isEmbeddable: Bool

        /// Seeds a link directly. Used by SwiftUI previews and tests.
        init(text: String, url: URL, isEmbeddable: Bool) {
            self.text = text
            self.url = url
            self.isEmbeddable = isEmbeddable
        }

        /// `nil` without copy or an `http(s)` URL, since the link would do nothing when tapped.
        init?(item: PayPalCreditMessageItem) {
            let text = CreditMessageContent.compose([item])
            guard !text.isEmpty, let url = item.clickURL, ["http", "https"].contains(url.scheme?.lowercased()) else {
                return nil
            }

            self.init(text: text, url: url, isEmbeddable: item.isEmbeddable ?? false)
        }
    }

    /// The non-tappable copy: main block plus any disclaimer block, space-joined.
    let message: String

    /// The "Learn more" link, or `nil` when PayPal sent no usable action.
    let learnMore: LearnMore?

    /// Seeds content directly. Used by SwiftUI previews and tests, which have no network response.
    init(message: String, learnMore: LearnMore?) {
        self.message = message
        self.learnMore = learnMore
    }

    /// Composes the content, or returns `nil` when there is no main copy to display (hide the row).
    init?(result: PayPalCreditMessagingResult) {
        let mainText = Self.compose(result.mainItems)
        guard !mainText.isEmpty else { return nil }

        // Order per PayPal: main, then disclaimers (empty today, may be enabled later), then action.
        let disclaimerText = Self.compose(result.disclaimerItems)
        self.message = [mainText, disclaimerText].filter { !$0.isEmpty }.joined(separator: " ")

        self.learnMore = result.actionItems.lazy.compactMap(LearnMore.init(item:)).first
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
