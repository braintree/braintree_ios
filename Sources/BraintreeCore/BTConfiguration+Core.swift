import Foundation

/// Extends `BTConfiguration` to access module-specific merchant account properties.
extension BTConfiguration {

    /// Indicates whether GraphQL is enabled for the merchant account.
    var isGraphQLEnabled: Bool {
        (json?["graphQL"]["url"].asString()?.count ?? 0) > 0
    }

    /// The merchant ID
    var merchantID: String? {
        json?["merchantId"].asString()
    }
}
