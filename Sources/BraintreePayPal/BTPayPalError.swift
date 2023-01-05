import Foundation

/// Error codes associated with PayPal.
enum BTPayPalError: Error, CustomNSError, LocalizedError {
    /// Unknown error
    case unknown
    
    /// PayPal is disabled in configuration
    case disabled

    /// Braintree SDK is integrated incorrectly
    case integration
    
    /// Payment flow was canceled, typically initiated by the user when exiting early from the flow.
    case canceled

    /// Failed to fetch Braintree configuration
    case fetchConfigurationFailed

    /// HTTP response is missing user info JSON data
    case httpResponseMissingUserInfoJSON

    /// HTTP POST request returned an error
    case httpPostRequestError([String: Any])

    /// The approval or redirect URL is invalid
    case invalidURL

    /// The ASWebAuthenticationSession URL is invalid
    case asWebAuthenticationSessionURLInvalid(String)

    /// The URL action is invalid
    case invalidURLAction

    /// Unable to create BTPayPalAccountNonce
    case failedToCreateNonce
    
    static var errorDomain: String {
        "com.braintreepayments.BTPayPalErrorDomain"
    }

    var errorCode: Int {
        switch self {
        case .unknown:
            return 0
        case .disabled:
            return 1
        case .integration:
            return 2
        case .canceled:
            return 3
        case .fetchConfigurationFailed:
            return 4
        case .httpResponseMissingUserInfoJSON:
            return 5
        case .httpPostRequestError:
            return 6
        case .invalidURL:
            return 7
        case .asWebAuthenticationSessionURLInvalid:
            return 8
        case .invalidURLAction:
            return 9
        case .failedToCreateNonce:
            return 10
        }
    }

    var errorDescription: String? {
        switch self {
        case .unknown:
            return ""
        case .disabled:
            return "PayPal is not enabled for this merchant. Enable PayPal for this merchant in the Braintree Control Panel."
        case .integration:
            return "BTPayPalClient failed because request is not of type BTPayPalCheckoutRequest or BTPayPalVaultRequest."
        case .canceled:
            return "PayPal flow was canceled by the user."
        case .fetchConfigurationFailed:
            return "Failed to fetch Braintree configuration."
        case .httpResponseMissingUserInfoJSON:
            return "HTTP POST request is missing user info JSON in the error response."
        case .httpPostRequestError(let error):
            return "HTTP POST request failed with \(error)."
        case .invalidURL:
            return "The approval and/or return URL contained an invalid URL. Try again or contact Braintree Support."
        case .asWebAuthenticationSessionURLInvalid(let scheme):
            return "Attempted to open an invalid URL in ASWebAuthenticationSession: \(scheme)://. Try again or contact Braintree Support."
        case .invalidURLAction:
            return "The URL action did not contain a valid URL."
        case .failedToCreateNonce:
            return "Unable to create BTPayPalAccountNonce. Either body did not contain paypalAccounts array or contents could not be parsed."
        }
    }
}
