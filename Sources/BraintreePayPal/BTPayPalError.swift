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

    /// 4. The web approval URL, web redirect URL, or PayPal native app approval URL is invalid
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

    /// 10. Return URL is invalid
    case invalidReturnURL(String)

    /// 11. Unknown app switch error occurred.
    case unknownAppSwitchError

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
        case .invalidReturnURL:
            return 10
        case .unknownAppSwitchError:
            return 11
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
            return "An error occured with retrieving a PayPal authentication URL: \(error)"
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
        case .invalidReturnURL(let missingValue):
            return "Return URL is missing \(missingValue)"
        case .unknownAppSwitchError:
            return "An unknown error occurred during the App Switch flow."
        }
    }

    // MARK: - Equatable Conformance

    public static func == (lhs: BTPayPalError, rhs: BTPayPalError) -> Bool {
        lhs.errorCode == rhs.errorCode
    }
}
