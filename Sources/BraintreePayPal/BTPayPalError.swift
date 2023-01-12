import Foundation

/// Error codes associated with PayPal.
enum BTPayPalError: Error, CustomNSError, LocalizedError {

    /// PayPal is disabled in configuration
    case disabled

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
        case .disabled:
            return 0
        case .canceled:
            return 1
        case .fetchConfigurationFailed:
            return 2
        case .httpResponseMissingUserInfoJSON:
            return 3
        case .httpPostRequestError:
            return 4
        case .invalidURL:
            return 5
        case .asWebAuthenticationSessionURLInvalid:
            return 6
        case .invalidURLAction:
            return 7
        case .failedToCreateNonce:
            return 8
        }
    }

    var errorDescription: String? {
        switch self {
        case .disabled:
            return "PayPal is not enabled for this merchant. Enable PayPal for this merchant in the Braintree Control Panel."
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
