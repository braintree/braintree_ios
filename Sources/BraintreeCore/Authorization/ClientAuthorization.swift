import UIKit

/// :nodoc: Form of authorization to interact with the Braintree gateway.
@_documentation(visibility: private)
public protocol ClientAuthorization {
    
    var type: AuthorizationType { get }
    
    /// The URL
    var configURL: URL { get }
    
    /// The bearer token to use for authenticating API calls. 
    /// The authorization fingerprint if a client token, or the full tokenization key if a tokenization key.
    var bearer: String { get }
    
    /// The original, full string value of the authorization string provided by the merchant. 
    /// The full client token or tokenization key.
    var originalValue: String { get } // TODO: rawValue re-name
}

/// :nodoc:
@_documentation(visibility: private)
public enum AuthorizationType {
    case tokenizationKey
    case clientToken
}
