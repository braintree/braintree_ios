import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The buyer's PayPal account.
struct BTPayPalPayer: Equatable {

    // MARK: - Internal Properties

    /// The email address associated with the buyer's PayPal account.
    let email: String?

    /// Whether the buyer is allowed to change the funding instrument PayPal will charge.
    let isEditable: Bool

    // MARK: - Initializer

    init?(json: BTJSON) {
        guard json.isObject else {
            return nil
        }

        self.email = json["email"].asString()
        self.isEditable = json["editable"].asBool() ?? false
    }
}
