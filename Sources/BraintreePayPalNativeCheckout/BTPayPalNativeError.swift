import Foundation

/// Error returned from the native PayPal flow
enum BTPayPalNativeError: Error, CustomNSError, LocalizedError, Equatable  {
    static func == (lhs: BTPayPalNativeError, rhs: BTPayPalNativeError) -> Bool {
        lhs.errorCode == rhs.errorCode
    }

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
    case orderCreationFailed(Error)

    /// PayPal flow was canceled by the user
    case canceled

    /// PayPalCheckout SDK returned an error
    case checkoutSDKFailed

    /// Tokenization with the Braintree Gateway failed
    case tokenizationFailed(Error)

    /// Failed to parse tokenization result
    case parsingTokenizationResultFailed

    case invalidJSONResponse

    static var errorDomain: String {
        "com.braintreepayments.BTPaypalNativeCheckoutErrorDomain"
    }

    var errorCode: Int {
        switch self {
        case .invalidRequest:
            return 0
        case .fetchConfigurationFailed:
            return 1
        case .payPalNotEnabled:
            return 2
        case .payPalClientIDNotFound:
            return 3
        case .invalidEnvironment:
            return 4
        case .orderCreationFailed:
            return 5
        case .canceled:
            return 6
        case .checkoutSDKFailed:
            return 7
        case .tokenizationFailed:
            return 8
        case .parsingTokenizationResultFailed:
            return 9
        case .invalidJSONResponse:
            return 10
        }
    }

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
        case .orderCreationFailed(let error):
            return "Failed to create PayPal order: \(error.localizedDescription)"
        case .canceled:
            return "PayPal flow was canceled by the user."
        case .checkoutSDKFailed:
            return "PayPalCheckout SDK returned an error."
        case .tokenizationFailed(let error):
            return "Tokenization with the Braintree Gateway failed: \(error.localizedDescription)"
        case .parsingTokenizationResultFailed:
            return "Failed to parse tokenization result."
        case .invalidJSONResponse:
            return "Invalid JSON response."
        }
    }
}
