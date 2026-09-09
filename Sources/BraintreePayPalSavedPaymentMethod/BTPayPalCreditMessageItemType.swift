import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The kind of content block making up a presentment message.
enum BTPayPalCreditMessageItemType: String {

    /// A logo image, with `alternativeText` as its alt text.
    case image = "IMAGE"

    /// Tappable copy that opens `clickURL`, such as "Learn more".
    case link = "LINK"

    /// Plain copy.
    case text = "TEXT"

    // MARK: - Initializer

    /// Parses the `type` field of a content block.
    /// - Returns: `nil` when PayPal returns a type this SDK version does not recognize.
    init?(json: BTJSON) {
        guard let rawValue = json.asString(), let type = Self(rawValue: rawValue) else {
            return nil
        }

        self = type
    }
}
