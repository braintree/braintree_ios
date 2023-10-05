import Foundation
import PayPalCheckout

/// Error returned from the native PayPal flow
enum BTPayPalNativeCheckoutError: Error, CustomNSError, LocalizedError, Equatable  {
    static func == (lhs: BTPayPalNativeCheckoutError, rhs: BTPayPalNativeCheckoutError) -> Bool {
        lhs.errorCode == rhs.errorCode
    }

    /// 0. Request is not of type BTPayPalNativeCheckoutRequest or BTPayPalNativeVaultRequest
    case invalidRequest

    /// 1. Failed to fetch Braintree configuration
    case fetchConfigurationFailed

    /// 2. PayPal is not enabled for this merchant in the Braintree Control Panel
    case payPalNotEnabled

    /// 3. Could not find PayPal client ID in the Braintree configuration
    case payPalClientIDNotFound

    /// 4. Invalid environment identifier found in the Braintree configuration
    case invalidEnvironment

    /// 5. Failed to create PayPal order
    case orderCreationFailed(Error)

    /// 6. PayPal flow was canceled by the user
    case canceled

    /// 7. PayPalCheckout SDK returned an error
    case checkoutSDKFailed(PayPalCheckout.ErrorInfo)

    /// 8. Tokenization with the Braintree Gateway failed
    case tokenizationFailed(Error)

    /// 9. Failed to parse tokenization result
    case parsingTokenizationResultFailed

    /// 10. Invalid JSON response
    case invalidJSONResponse

    /// 11. Deallocated BTPayPalNativeCheckoutClient
    case deallocated
  
    /// 12. Missing return url in approval data
    case missingReturnURL

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
        case .deallocated:
            return 11
        case .missingReturnURL:
            return 12
        }
    }

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
        case .orderCreationFailed(let error):
            return "Failed to create PayPal order: \(error.localizedDescription)"
        case .canceled:
            return "PayPal flow was canceled by the user."
        case .checkoutSDKFailed(let error):
            return "PayPalCheckout SDK returned an error: \(error.description)"
        case .tokenizationFailed(let error):
            return "Tokenization with the Braintree Gateway failed: \(error.localizedDescription)"
        case .parsingTokenizationResultFailed:
            return "Failed to parse tokenization result."
        case .invalidJSONResponse:
            return "Invalid JSON response."
        case .deallocated:
            return "BTPayPalNativeCheckoutClient has been deallocated."
        case .missingReturnURL:
            return "Return URL is missing from the approval data."
        }
    }
}
