import Foundation

///  BTPaymentMethodNonce is for generic tokenized payment information.
///
///  For example, if a customer's vaulted payment methods contains a type that's not recognized or supported by the
///  Braintree SDK or the client-side integration (e.g. the vault contains a PayPal account but the client-side
///  integration does not include the PayPal component), this type can act as a fallback.
///
///  The payment method nonce is a public token that acts as a placeholder for sensitive payments data that
///  has been uploaded to Braintree for subsequent processing. The nonce is safe to access on the client and can be
///  used on your server to reference the data in Braintree operations, such as Transaction.sale.
@objc public protocol BTPaymentMethodNonce: AnyObject {

    /// The one-time use payment method nonce
    var nonce: String { get set }

    /// The type of the tokenized data, e.g. PayPal, Venmo, MasterCard, Visa, Amex
    var type: String { get set }

    /// `true` if this nonce is the customer's default payment method, otherwise `false`
    var isDefault: Bool { get set }

    /// Initialize a new Payment Method Nonce.
    /// - Parameter nonce: A transact-able payment method nonce.
    /// - Returns: A Payment Method Nonce, or `nil` if nonce is nil.
    @objc optional func initWithNonce(nonce: String) -> BTPaymentMethodNonce?

    /// Initialize a new Payment Method Nonce.
    /// - Parameters:
    ///   - nonce: A transact-able payment method nonce.
    ///   - type: A string identifying the type of the payment method.
    /// - Returns: A Payment Method Nonce, or `nil` if nonce is nil.
    @objc optional func initWithNonce(nonce: String, type: String) -> BTPaymentMethodNonce?

    /// Initialize a new Payment Method Nonce.
    /// - Parameters:
    ///   - nonce: A transact-able payment method nonce.
    ///   - type: A string identifying the type of the payment method.
    ///   - isDefault: A boolean indicating whether this is a default payment method.
    /// - Returns: A Payment Method Nonce, or `nil` if nonce is nil.
    @objc optional func initWithNonce(nonce: String, type: String, isDefault: Bool) -> BTPaymentMethodNonce?
}

extension BTPaymentMethodNonce {
    func initWithNonce(nonce: String) -> BTPaymentMethodNonce? {
        self.initWithNonce?(nonce: nonce, type: "Unknown")
    }

    func initWithNonce(nonce: String, type: String) -> BTPaymentMethodNonce? {
        self.initWithNonce?(nonce: nonce, type: type)
    }

    func initWithNonce(nonce: String, type: String, isDefault: Bool) -> BTPaymentMethodNonce? {
        self.initWithNonce?(nonce: nonce, type: type, isDefault: isDefault)
    }
}
