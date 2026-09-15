import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The funding instrument details for a vaulted PayPal payment method.
struct BTPayPalSavedPaymentMethodSummary: Equatable {

    // MARK: - Internal Properties

    /// The funding instruments PayPal can charge. The first entry is the one that will be charged.
    let paymentMethods: [BTPayPalSavedPaymentMethod]

    /// The buyer's PayPal account, when PayPal returns one.
    let payer: BTPayPalPayer?

    // MARK: - Initializer

    /// Parses the `paypalFundingInstrumentDetails` field of a `PaypalFundingInstrumentDetails` response.
    /// - Returns: `nil` when the field is not an object.
    init?(json: BTJSON) {
        guard json.isObject else {
            return nil
        }

        self.paymentMethods = json["paymentMethods"].asArray()?.compactMap(BTPayPalSavedPaymentMethod.init) ?? []
        self.payer = BTPayPalPayer(json: json["payer"])
    }
}
