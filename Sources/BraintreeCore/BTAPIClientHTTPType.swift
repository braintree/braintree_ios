import Foundation

/// :nodoc: This enum is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
@_documentation(visibility: private)
@objc public enum BTAPIClientHTTPService: Int {
    /// Use the Gateway
    case gateway

    /// Use the GraphQL API
    case graphQLAPI
    
    /// Use the PayPal API
    case payPalAPI
}
