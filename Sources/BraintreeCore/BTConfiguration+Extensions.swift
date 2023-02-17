import Foundation

// NEXT_MAJOR_VERSION (v7): these extensions should be moved into their respective modules
// as the modules are converted to Swift.
// Also, determine whether they should remain public or become internal

/// Extends `BTConfiguration` to access module-specfic merchant account properties.
@objc public extension BTConfiguration {

    // MARK: - BTConfiguration+GraphQL

    /// Indicates whether GraphQL is enabled for the merchant account.
    var isGraphQLEnabled: Bool {
        (json?["graphQL"]["url"].asString()?.count ?? 0) > 0
    }

    // MARK: - BTConfiguration+Venmo

    /// Indicates whether Venmo is enabled for the merchant account.
    var isVenmoEnabled: Bool {
        venmoAccessToken != nil
    }

    /// Returns the Access Token used by the Venmo app to tokenize on behalf of the merchant.
    var venmoAccessToken: String? {
        json?["payWithVenmo"]["accessToken"].asString()
    }

    /// Returns the Venmo merchant ID used by the Venmo app to authorize payment.
    var venmoMerchantID: String? {
        json?["payWithVenmo"]["merchantId"].asString()
    }

    /// Returns the Venmo environment used to handle this payment.
    var venmoEnvironment: String? {
        json?["payWithVenmo"]["environment"].asString()
    }

    // MARK: - BTConfiguration+ThreeDSecure

    /// JWT for use with initializaing Cardinal 3DS framework
    var cardinalAuthenticationJWT: String? {
        json?["threeDSecure"]["cardinalAuthenticationJWT"].asString()
    }

    // MARK: - BTConfiguration+PaymentFlow

    /// Indicates whether Local Payments are enabled for the merchant account.
    var isLocalPaymentEnabled: Bool {
        // Local Payments are enabled when PayPal is enabled
        json?["paypalEnabled"].isTrue ?? false
    }
}
