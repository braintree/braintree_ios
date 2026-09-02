import Foundation

/// The kind of content block making up a presentment message.
enum BTPayPalCreditMessageItemType: String {

    /// A logo image, with `alternativeText` as its alt text.
    case image = "IMAGE"

    /// Tappable copy that opens `clickURL`, such as "Learn more".
    case link = "LINK"

    /// Plain copy.
    case text = "TEXT"
}
