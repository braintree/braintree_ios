import Foundation

/// The kind of content block making up a presentment message.
enum BTPayPalCreditMessageItemType: String {

    case image = "IMAGE"
    case link = "LINK"
    case text = "TEXT"
    case textVariable = "TEXT_VARIABLE"
}
