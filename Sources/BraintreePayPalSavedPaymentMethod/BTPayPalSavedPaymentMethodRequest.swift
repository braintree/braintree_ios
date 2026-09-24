import Foundation

/// The inputs `BTPayPalSavedPaymentMethodView` needs to resolve the buyer's saved funding
/// instrument and its accompanying Pay Later message.
public struct BTPayPalSavedPaymentMethodRequest: Equatable {

    // MARK: - Public Properties

    /// Drives the inline Pay Later message. Must match `payPalCheckoutRequest.amount`.
    public let amount: String

    /// ISO-4217 currency for `amount`. Must match `payPalCheckoutRequest.currencyCode`.
    public let currencyCode: String

    /// The merchant account the funding instrument is resolved against. Omit for the default.
    public let merchantAccountID: String?

    // MARK: - Initializer

    /// Creates a `BTPayPalSavedPaymentMethodRequest`.
    /// - Parameters:
    ///   - amount: Required. The order amount the Pay Later message is calculated from, e.g. `"55.00"`.
    ///   - currencyCode: Required. A three-character ISO-4217 currency code for `amount`.
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
