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
//@objcMembers public class BTPaymentMethodNonce: NSObject, BTPaymentMethodNonceDelegate {
//
//    public var nonce: String
//
//    public var type: String
//
//    public var isDefault: Bool
//
//    /// Initialize a new Payment Method Nonce.
//    /// - Parameter nonce: A transact-able payment method nonce.
//    /// - Returns: A Payment Method Nonce, or `nil` if nonce is nil.
//    @objc(initWithNonce:)
//    public init(nonce: String) {
//        self.nonce = nonce
//        self.type = "Unknown"
//        self.isDefault = false
//    }
//
//    /// Initialize a new Payment Method Nonce.
//    /// - Parameters:
//    ///   - nonce: A transact-able payment method nonce.
//    ///   - type: A string identifying the type of the payment method.
//    /// - Returns: A Payment Method Nonce, or `nil` if nonce is nil.
//    @objc(initWithNonce:type:)
//    public init(nonce: String, type: String) {
//        self.nonce = nonce
//        self.type = type
//        self.isDefault = false
//    }
//
//    /// Initialize a new Payment Method Nonce.
//    /// - Parameters:
//    ///   - nonce: A transact-able payment method nonce.
//    ///   - type: A string identifying the type of the payment method.
//    ///   - isDefault: A boolean indicating whether this is a default payment method.
//    /// - Returns: A Payment Method Nonce, or `nil` if nonce is nil.
//    @objc(initWithNonce:type:isDefault:)
//    public init(nonce: String, type: String, isDefault: Bool) {
//        self.nonce = nonce
//        self.type = type
//        self.isDefault = isDefault
//    }
//}

@objc public protocol BTPaymentMethodNonce: AnyObject {
    /// The one-time use payment method nonce
    var nonce: String? { get set }

    /// The type of the tokenized data, e.g. PayPal, Venmo, MasterCard, Visa, Amex
    var type: String? { get set }

    /// `true` if this nonce is the customer's default payment method, otherwise `false`
    var isDefault: Bool { get set }

    @objc optional static func initWithNonce(_ nonce: String)

    @objc optional static func initWithNonce(_ nonce: String, type: String)

    @objc optional static func initWithNonce(_ nonce: String, type: String, isDefault: Bool)
}

extension BTPaymentMethodNonce {
    func initWithNonce(_ nonce: String) {
        initWithNonce(nonce, type: "Unknown", isDefault: false)
    }

    func initWithNonce(_ nonce: String, type: String) {
        self.nonce = nonce
        self.type = type
    }

    func initWithNonce(_ nonce: String, type: String, isDefault: Bool) {
        self.nonce = nonce
        self.type = type
        self.isDefault = isDefault
    }
}
