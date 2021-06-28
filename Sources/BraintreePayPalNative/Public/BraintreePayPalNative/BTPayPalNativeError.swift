import Foundation

/**
 Error returned from the native PayPal flow
 */
@objc public enum BTPayPalNativeError: Int, LocalizedError {
    /// Request is not of type BTPayPalNativeCheckoutRequest or BTPayPalNativeVaultRequest
    case invalidRequest

    /// Failed to fetch Braintree configuration
    case fetchConfigurationFailed

    /// PayPal is not enabled for this merchant in the Braintree Control Panel
    case payPalNotEnabled

    /// Could not find PayPal client ID in the Braintree configuration
    case payPalClientIDNotFound

    /// Invalid environment identifier found in the Braintree configuration
    case invalidEnvironment

    /// Failed to create PayPal order
    case orderCreationFailed

    /// PayPal flow was canceled by the user
    case canceled

    /// PayPalCheckout SDK returned an error
    case checkoutSDKFailed

    /// Tokenization with the Braintree Gateway failed
    case tokenizationFailed

    /// Failed to parse tokenization result
    case parsingTokenizationResultFailed

    /// PayPalCheckoutSDK did not provide a return URL
    case returnURLNotFound

    public var errorDescription: String? {
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
        case .canceled:
            return "PayPal flow was canceled by the user."
        case .checkoutSDKFailed:
            return "PayPalCheckout SDK returned an error."
        case .tokenizationFailed:
            return "Tokenization with the Braintree Gateway failed."
        case .parsingTokenizationResultFailed:
            return "Failed to parse tokenization result."
        case .returnURLNotFound:
            return "PayPalCheckout SDK did not provide a return URL."
        }
    }
}
