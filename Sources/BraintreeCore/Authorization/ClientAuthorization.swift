import UIKit

/// :nodoc: Form of authorization to interact with the Braintree gateway.
@_documentation(visibility: private)
public protocol ClientAuthorization {

    /// :nodoc: Enum to denote Authorization type of Tokenization Key or Client Token.
    var type: AuthorizationType { get }
    
    /// :nodoc: The URL derived from this auth credential used to fetch the configuration.
    var configURL: URL { get }
    
    /// :nodoc: The bearer token to use for authenticating API calls.
    /// The authorization fingerprint if a client token, or the full tokenization key if a tokenization key.
    var bearer: String { get }
    
    /// :nodoc: The original, full string value of the authorization string provided by the merchant.
    /// The full client token or tokenization key.
    var originalValue: String { get }

    /// :nodoc: The payment method ID JWT extracted from the client token, if present. Used by the
    /// PayPal Edit FI flow to reference an existing billing agreement. `nil` when not present
    /// (e.g. tokenization keys, or client tokens that don't include it).
    var paymentMethodIDJWT: String? { get }
}

/// :nodoc: Default so existing conformers are unaffected; only client tokens provide a value.
@_documentation(visibility: private)
extension ClientAuthorization {

    public var paymentMethodIDJWT: String? { nil }
}

/// :nodoc:
@_documentation(visibility: private)
public enum AuthorizationType {
    case tokenizationKey
    case clientToken
    case invalidAuthorization
}
