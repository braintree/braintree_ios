import Foundation

/// :nodoc:
// TODO: rename once Objective-C files are deleted
@objc public enum BTAPIClientHTTPTypeSwift: Int {
    /// Use the Gateway
    case gateway

    /// Use the Braintree API
    case braintreeAPI

    /// Use the GraphQL API
    case graphQLAPI
}
