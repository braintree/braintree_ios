import BraintreePayPal

/// The request that configures a `BTPayPalSavedPaymentMethodView`.
///
/// The buyer's funding instrument is resolved by the SDK from the client token
/// (the `paymentMethodIdJwt` is extracted internally when the edit flow is wired in),
/// so the merchant does not pass any FI identifier here. The wrapped `payPalRequest`
/// is forwarded, unchanged, to the PayPal client when the buyer taps Edit — exactly
/// like `PayPalButton` forwards its request — so its amount and required fields must
/// reflect the live cart at edit time.
public struct BTPayPalSavedPaymentMethodRequest {

    // MARK: - Public Properties

    /// The PayPal Checkout request forwarded to the client when the buyer taps Edit.
    ///
    /// The edit flow creates a `create_payment_resource` order, so this is a
    /// `BTPayPalCheckoutRequest`. Its `amount` also drives the optional credit
    /// (Pay Later) messaging line.
    public let payPalRequest: BTPayPalCheckoutRequest

    /// Whether to render the inline credit (Pay Later) messaging line below the FI row.
    /// Defaults to `false`.
    public let showCreditMessage: Bool

    // MARK: - Initializer

    /// Creates a request for `BTPayPalSavedPaymentMethodView`.
    /// - Parameters:
    ///   - payPalRequest: The PayPal Checkout request forwarded on edit; its amount drives credit messaging.
    ///   - showCreditMessage: Whether to render the inline credit messaging line. Defaults to `false`.
    public init(
        payPalRequest: BTPayPalCheckoutRequest,
        showCreditMessage: Bool = false
    ) {
        self.payPalRequest = payPalRequest
        self.showCreditMessage = showCreditMessage
    }
}
