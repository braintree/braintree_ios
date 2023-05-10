import Foundation

/// :nodoc:
@_documentation(visibility: private)
@objc public enum BTAPIClientHTTPService: Int {
    /// Use the Gateway
    case gateway

    /// Use the Braintree API
    case braintreeAPI

    /// Use the GraphQL API
    case graphQLAPI
}
