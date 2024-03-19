import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

enum BTVenmoAppSwitchReturnURLState {
    case unknown
    case succeededWithPaymentContext
    case succeeded
    case failed
    case canceled
}

///  This class interprets URLs received from the Venmo app via app switch returns.
///
///  Venmo Touch app switch authorization requests should result in success, failure or user-initiated cancelation. These states are communicated in the url.
struct BTVenmoAppSwitchReturnURL {

    // MARK: - Properties

    /// The overall status of the app switch - success, failure or cancelation
    var state: BTVenmoAppSwitchReturnURLState = .unknown

    /// The nonce from the return URL.
    var nonce: String?

    /// The username from the return URL.
    var username: String?

    /// The payment context ID from the return URL.
    var paymentContextID: String?

    /// If the return URL's state is BTVenmoAppSwitchReturnURLStateFailed, the error returned from Venmo via the app switch.
    var error: Error?

    // MARK: - Initializer

    /// Initializes a new BTVenmoAppSwitchReturnURL
    /// - Parameter url: an incoming app switch url
    init?(url: URL) {
        let parameters = BTURLUtils.queryParameters(for: url)

        if url.path == "/vzero/auth/venmo/success" {
            if let resourceID = parameters["resource_id"] {
                state = .succeededWithPaymentContext
                paymentContextID = resourceID
            } else {
                state = .succeeded
                nonce = parameters["paymentMethodNonce"] ?? parameters["payment_method_nonce"]
                username = parameters["username"]
            }
        } else if url.path == "/vzero/auth/venmo/error" {
            state = .failed
            let errorMessage: String? = parameters["errorMessage"] ?? parameters["error_message"]
            let errorCode = Int(parameters["errorCode"] ?? parameters["error_code"] ?? "0")
            error = BTVenmoAppSwitchError.returnURLError(errorCode ?? 0, errorMessage)
        } else if url.path == "/vzero/auth/venmo/cancel" {
            state = .canceled
        } else {
            state = .unknown
        }
    }

    // MARK: - Internal Methods

    /// Evaluates whether the url represents a valid Venmo Touch return.
    /// - Parameter url: an app switch return URL
    /// - Returns: `true` if the url represents a Venmo Touch app switch return
    static func isValid(url: URL) -> Bool {
        url.host == "x-callback-url" && url.path.hasPrefix("/vzero/auth/venmo/")
    }
}
