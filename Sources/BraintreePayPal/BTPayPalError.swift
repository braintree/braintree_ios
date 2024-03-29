import Foundation

/// Error codes associated with PayPal.
public enum BTPayPalError: Error, CustomNSError, LocalizedError, Equatable {

    /// 0. PayPal is disabled in configuration
    case disabled

    /// 1. Payment flow was canceled, typically initiated by the user when exiting early from the flow.
    case canceled

    /// 2. Failed to fetch Braintree configuration
    case fetchConfigurationFailed

    /// 3. HTTP POST request returned an error
    case httpPostRequestError([String: Any])

    /// 4. The web approval URL, web redirect URL, App Switch return URL, PayPal native app approval URL is invalid
    case invalidURL(String)

    /// 5. The ASWebAuthenticationSession URL is invalid
    case asWebAuthenticationSessionURLInvalid(String)

    /// 6. The URL action is invalid
    case invalidURLAction

    /// 7. Unable to create BTPayPalAccountNonce
    case failedToCreateNonce
    
    /// 8. ASWebAuthentication error
    case webSessionError(Error)

    /// 9. Deallocated BTPayPalClient
    case deallocated

    /// 10. The App Switch return URL did not contain the cancel or success path.
    case appSwitchReturnURLPathInvalid

    public static var errorDomain: String {
        "com.braintreepayments.BTPayPalErrorDomain"
    }

    public var errorCode: Int {
        switch self {
        case .disabled:
            return 0
        case .canceled:
            return 1
        case .fetchConfigurationFailed:
            return 2
        case .httpPostRequestError:
            return 3
        case .invalidURL:
            return 4
        case .asWebAuthenticationSessionURLInvalid:
            return 5
        case .invalidURLAction:
            return 6
        case .failedToCreateNonce:
            return 7
        case .webSessionError:
            return 8
        case .deallocated:
            return 9
        case .appSwitchReturnURLPathInvalid:
            return 10
        }
    }

    public var errorDescription: String? {
        switch self {
        case .disabled:
            return "PayPal is not enabled for this merchant. Enable PayPal for this merchant in the Braintree Control Panel."
        case .canceled:
            return "PayPal flow was canceled by the user."
        case .fetchConfigurationFailed:
            return "Failed to fetch Braintree configuration."
        case .httpPostRequestError(let error):
            return "HTTP POST request failed with \(error)."
        case .invalidURL(let error):
            return "An error occurred with retrieving a PayPal URL: \(error)"
        case .asWebAuthenticationSessionURLInvalid(let scheme):
            return "Attempted to open an invalid URL in ASWebAuthenticationSession: \(scheme)://. Try again or contact Braintree Support."
        case .invalidURLAction:
            return "The URL action did not contain a valid URL."
        case .failedToCreateNonce:
            return "Unable to create BTPayPalAccountNonce. Either body did not contain paypalAccounts array or contents could not be parsed."
        case .webSessionError(let error):
            return "ASWebAuthenticationSession failed with \(error.localizedDescription)"
        case .deallocated:
            return "BTPayPalClient has been deallocated."
        case .appSwitchReturnURLPathInvalid:
            return "The App Switch return URL did not contain the cancel or success path."
        }
    }

    // MARK: - Equatable Conformance

    public static func == (lhs: BTPayPalError, rhs: BTPayPalError) -> Bool {
        lhs.errorCode == rhs.errorCode
    }
}
