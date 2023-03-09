import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

// TODO: enum can be internal and non-int once rest of Venmo is in Swift
@objc public enum BTVenmoAppSwitchReturnURLState: Int {
    case unknown
    case succeededWithPaymentContext
    case succeeded
    case failed
    case canceled
}

///  This class interprets URLs received from the Venmo app via app switch returns.
///
///  Venmo Touch app switch authorization requests should result in success, failure or user-initiated cancelation. These states are communicated in the url.
// TODO: Entire class be internal and likely a struct once rest of Venmo is in Swift
@objcMembers public class BTVenmoAppSwitchReturnURL: NSObject {

    // MARK: - Properties

    /// The overall status of the app switch - success, failure or cancelation
    public var state: BTVenmoAppSwitchReturnURLState = .unknown

    /// The nonce from the return URL.
    public var nonce: String?

    /// The username from the return URL.
    public var username: String?

    /// The payment context ID from the return URL.
    public var paymentContextID: String?

    /// If the return URL's state is BTVenmoAppSwitchReturnURLStateFailed, the error returned from Venmo via the app switch.
    public var error: Error?

    // MARK: - Initializer

    /// Initializes a new BTVenmoAppSwitchReturnURL
    /// - Parameter url: an incoming app switch url
    @objc(initWithURL:)
    public init?(url: URL) {
        let parameters = BTURLUtils.queryParameters(for: url)

        if url.path == "/vzero/auth/venmo/success" {
            if let resourceID = parameters["resource_id"] {
                state = .succeededWithPaymentContext
                paymentContextID = resourceID
            } else {
                state = .succeeded
                nonce = parameters["paymentMethodNonce"]
                username = parameters["username"]
            }
        } else if url.path == "/vzero/auth/venmo/error" {
            state = .failed
            let errorMessage: String? = parameters["errorMessage"]
            let errorCode = Int(parameters["errorCode"] ?? "0")
            error = BTVenmoAppSwitchError.returnURLError(errorCode ?? 0, errorMessage)
        } else if url.path == "/vzero/auth/venmo/cancel" {
            state = .canceled
        } else {
            state = .unknown
        }
    }

    // MARK: - Internal Methods
    // TODO: method can be non-static and internal once rest of Venmo is in Swift

    /// Evaluates whether the url represents a valid Venmo Touch return.
    /// - Parameter url: an app switch return URL
    /// - Returns: `true` if the url represents a Venmo Touch app switch return
    @objc(isValidURL:)
    public static func isValid(url: URL) -> Bool {
        url.host == "x-callback-url" && url.path.hasPrefix("/vzero/auth/venmo/")
    }
}
