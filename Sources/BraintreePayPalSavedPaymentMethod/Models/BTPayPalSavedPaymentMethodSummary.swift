import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The funding instrument details for a vaulted PayPal payment method.
///
/// The response is mutually exclusive: PayPal returns either the funding instruments or a display-only `payer`, never both.
/// When both are empty there is nothing to display for this buyer.
struct BTPayPalSavedPaymentMethodSummary: Equatable {

    // MARK: - Internal Properties

    /// The buyer's PayPal account, populated only when the funding instrument itself cannot be displayed.
    let payer: BTPayPalPayer?

    /// The funding instruments PayPal can charge. The first entry is the one that will be charged.
    let paymentMethods: [BTPayPalSavedPaymentMethod]

    // MARK: - Initializer

    init?(json: BTJSON) {
        guard json.isObject else {
            return nil
        }

        self.payer = BTPayPalPayer(json: json["payer"])
        self.paymentMethods = json["paymentMethods"].asArray()?.map(BTPayPalSavedPaymentMethod.init) ?? []
    }
}
