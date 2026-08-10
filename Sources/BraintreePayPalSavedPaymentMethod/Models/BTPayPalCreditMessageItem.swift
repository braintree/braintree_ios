import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// A single block of a presentment message. Blocks are returned in the order they must be displayed.
struct BTPayPalCreditMessageItem: Equatable {

    // MARK: - Internal Properties

    /// The kind of block, or `nil` when PayPal returns a type this SDK version does not recognize.
    let type: BTPayPalCreditMessageItemType?

    /// The copy to display, for example `"4 interest-free payments of $13.75 with "`.
    let text: String?

    /// The screen reader text for blocks whose `text` relies on symbols or abbreviations.
    let alternativeText: String?

    /// The URL to open when a `link` or `image` block is tapped.
    let clickURL: URL?

    /// The image to render for an `image` block.
    let sourceURL: URL?

    /// A non-unique identifier for the block, for example `"periodic_payment_count"` or `"paypal_logo"`.
    let name: String?

    /// Whether `clickURL` may be loaded in an embedded web view rather than an external browser.
    let isEmbeddable: Bool

    // MARK: - Initializer

    init(json: BTJSON) {
        self.type = json["type"].asString().flatMap(BTPayPalCreditMessageItemType.init(rawValue:))
        self.text = json["text"].asString()
        self.alternativeText = json["alternative_text"].asString()
        self.clickURL = json["click_url"].asURL()
        self.sourceURL = json["source_url"].asURL()
        self.name = json["name"].asString()
        self.isEmbeddable = json["embeddable"].asBool() ?? false
    }
}
