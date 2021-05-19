import Foundation

enum BTPayPalNativeError: Int, LocalizedError {
    case invalidRequest
    case fetchConfigurationFailed
    case payPalNotEnabled
    case payPalClientIDNotFound
    case invalidEnvironment
    case orderCreationFailed

    var errorDescription: String? {
        switch self {
        case .invalidRequest:
            return "Request is not of type BTPayPalNativeCheckoutRequest or BTPayPalNativeVaultRequest."
        case .fetchConfigurationFailed:
            return "Failed to fetch Braintree configuration."
        case .payPalNotEnabled:
            return "PayPal is not enabled for this merchant in the Braintree Control Panel."
        case .payPalClientIDNotFound:
            return "Could not find PayPal client ID in Braintree configuration."
        case .invalidEnvironment:
            return "Invalid environment identifier found in the Braintree configuration."
        case .orderCreationFailed:
            return "Failed to create PayPal order."
        }
    }
}
