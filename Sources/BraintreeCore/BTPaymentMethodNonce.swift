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
@objcMembers open class BTPaymentMethodNonce: NSObject {

    /// The payment method nonce.
    public var nonce: String

    /// The string identifying the type of the payment method.
    public var type: String

    /// The boolean indicating whether this is a default payment method.
    public var isDefault: Bool

    /// Initialize a new Payment Method Nonce.
    /// - Parameter nonce: A transact-able payment method nonce.
    /// - Returns: A Payment Method Nonce, or `nil` if nonce is nil.
    @objc(initWithNonce:)
    public init(nonce: String) {
        self.nonce = nonce
        self.type = "Unknown"
        self.isDefault = false
    }

    /// Initialize a new Payment Method Nonce.
    /// - Parameters:
    ///   - nonce: A transact-able payment method nonce.
    ///   - type: A string identifying the type of the payment method.
    /// - Returns: A Payment Method Nonce, or `nil` if nonce is nil.
    @objc(initWithNonce:type:)
    public init(nonce: String, type: String) {
        self.nonce = nonce
        self.type = type
        self.isDefault = false
    }

    /// Initialize a new Payment Method Nonce.
    /// - Parameters:
    ///   - nonce: A transact-able payment method nonce.
    ///   - type: A string identifying the type of the payment method.
    ///   - isDefault: A boolean indicating whether this is a default payment method.
    /// - Returns: A Payment Method Nonce, or `nil` if nonce is nil.
    @objc(initWithNonce:type:isDefault:)
    public init(nonce: String, type: String, isDefault: Bool) {
        self.nonce = nonce
        self.type = type
        self.isDefault = isDefault
    }
}
