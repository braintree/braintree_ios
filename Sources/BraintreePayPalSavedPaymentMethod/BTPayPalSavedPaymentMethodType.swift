import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The kind of funding instrument PayPal will charge.
enum BTPayPalSavedPaymentMethodType: String {

    /// A bank account linked to the buyer's PayPal account.
    case bank = "BANK"

    /// A credit or debit card.
    case card = "CARD"

    /// The buyer's PayPal Credit line.
    case payPalCredit = "PAYPAL_CREDIT"

    // MARK: - Initializer

    /// Parses the `type` field of a funding instrument.
    /// - Returns: `nil` when PayPal returns a type this SDK version does not recognize.
    init?(json: BTJSON) {
        guard let rawValue = json.asString(), let type = Self(rawValue: rawValue) else {
            return nil
        }

        self = type
    }
}
