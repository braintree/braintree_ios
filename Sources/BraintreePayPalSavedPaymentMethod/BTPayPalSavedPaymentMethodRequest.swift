import Foundation

/// The inputs `BTPayPalSavedPaymentMethodView` needs to resolve the buyer's saved funding
/// instrument and its accompanying Pay Later message.
/// - Warning: This feature is in beta. It's public API may change or be removed in future releases.
public struct BTPayPalSavedPaymentMethodRequest: Equatable {

    // MARK: - Internal Properties

    let amount: String
    let currencyCode: String
    let merchantAccountID: String?

    // MARK: - Initializer

    /// Creates a `BTPayPalSavedPaymentMethodRequest`.
    /// - Parameters:
    ///   - amount: Required. The order amount the Pay Later message is calculated from, e.g. `"55.00"`.
    ///     Must match `payPalCheckoutRequest.amount`.
    ///   - currencyCode: Required. A three-character ISO-4217 currency code for `amount`.
    ///     Must match `payPalCheckoutRequest.currencyCode`.
    ///   - merchantAccountID: Optional. A non-default merchant account to resolve the funding instrument against.
    public init(
        amount: String,
        currencyCode: String,
        merchantAccountID: String? = nil
    ) {
        self.amount = amount
        self.currencyCode = currencyCode
        self.merchantAccountID = merchantAccountID
    }
}
