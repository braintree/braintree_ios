import Foundation

/// :nodoc: This class is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
/// Contains information specific to a merchant's Braintree integration
@_documentation(visibility: private)
@objcMembers public class BTConfiguration: NSObject {

    /// :nodoc: This property is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// The merchant account's configuration as a `BTJSON` object
    public let json: BTJSON?

    /// :nodoc: This property is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// The environment (production or sandbox)
    public var environment: String? {
        json?["environment"].asString()
    }
    
    /// The Braintree GW URL to use for REST requests
    var clientAPIURL: URL? {
        json?["clientApiUrl"].asURL()
    }
    
    /// The Braintree GraphQL URL
    var graphQLURL: URL? {
        json?["graphQL"]["url"].asURL()
    }
    
    /// The environment name sent to PayPal's FPTI analytics service
    var fptiEnvironment: String? {
        environment == "production" ? "live" : environment
    }
    
    /// :nodoc: Timestamp of initialization of each `BTConfiguration` instance
    /// Mutable for testing.
    var time = Date().timeIntervalSince1970

    /// :nodoc: This initalizer is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    ///  Used to initialize a `BTConfiguration`
    /// - Parameter json: The `BTJSON` to initialize with
    @objc(initWithJSON:)
    public init(json: BTJSON?) {
        self.json = json
    }
}
