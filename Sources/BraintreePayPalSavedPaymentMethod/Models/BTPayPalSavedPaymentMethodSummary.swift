import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The funding instrument details for a vaulted PayPal payment method.
struct BTPayPalSavedPaymentMethodSummary: Equatable {

    // MARK: - Internal Properties

    /// The buyer's PayPal account, when PayPal returns one.
    let payer: BTPayPalPayer?

    /// The funding instruments PayPal can charge. The first entry is the one that will be charged.
    let paymentMethods: [BTPayPalSavedPaymentMethod]

    // MARK: - Initializer

    init?(json: BTJSON) {
        guard json.isObject else {
            return nil
        }

        self.payer = BTPayPalPayer(json: json["payer"])
        self.paymentMethods = json["paymentMethods"].asArray()?.compactMap(BTPayPalSavedPaymentMethod.init) ?? []
    }
}
