import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// A funding instrument PayPal can charge on the buyer's behalf.
struct BTPayPalSavedPaymentMethod: Equatable {

    // MARK: - Internal Properties

    /// The kind of funding instrument, or `nil` when PayPal returns a type this SDK version does not recognize.
    let type: BTPayPalSavedPaymentMethodType?

    /// The display name of the funding instrument, for example `"Visa"` or `"CREDIT UNION 1"`.
    let label: String?

    /// The card art or bank glyph to render alongside the label.
    let imageURL: URL?

    /// The last digits of the funding instrument's account number.
    let lastDigits: String?

    /// A further qualifier on `type`, for example the card's product name.
    let subtype: String?

    // MARK: - Initializer

    init(json: BTJSON) {
        self.type = json["type"].asString().flatMap(BTPayPalSavedPaymentMethodType.init(rawValue:))
        self.label = json["label"].asString()
        self.imageURL = json["imageUrl"].asURL()
        self.lastDigits = json["lastDigits"].asString()
        self.subtype = json["subtype"].asString()
    }
}
