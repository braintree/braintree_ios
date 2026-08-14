import BraintreePayPal

/// The terminal outcome of a `BTPayPalSavedPaymentMethodView` edit flow, delivered to the
/// merchant's `onResult` callback.
public enum BTPayPalSavedPaymentMethodResult {

    /// The buyer changed the funding instrument and the order was tokenized successfully.
    /// - Parameters:
    ///   - nonce: The tokenized PayPal account nonce to send to your server for the transaction.
    ///   - paymentToken: The approved-checkout order/payment token.
    ///   - fiSummary: The refreshed funding-instrument summary now reflected in the UI.
    case success(nonce: BTPayPalAccountNonce, paymentToken: String, fiSummary: BTPayPalSavedPaymentMethodFISummary)

    /// The buyer dismissed the paysheet without approving. The original sticky FI is kept.
    case cancel

    /// The flow failed. The original sticky FI is kept on screen.
    case failure(Error)
}
