import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

enum BTPayPalAppSwitchReturnURLState {
    case unknown
    case succeeded
    case canceled
}

/// This class interprets URLs received from the PayPal app via app switch returns.
///
/// PayPal app switch authorization requests should result in success or user-initiated cancelation. These states are communicated in the url.
struct BTPayPalAppSwitchReturnURL {

    /// The overall status of the app switch - success, failure or cancelation
    var state: BTPayPalAppSwitchReturnURLState = .unknown

    /// The EC Token from the return URL.
    var ecToken: String?

    /// The BA Token from the return URL.
    var baToken: String?

    /// The timestamp from the return URL.
    var timestamp: String?

    /// Initializes a new `BTPayPalAppSwitchReturnURL`
    /// - Parameter url: an incoming app switch url
    init?(url: URL) {
        let parameters = BTURLUtils.queryParameters(for: url)

        if url.path.contains("success") {
            state = .succeeded
            if let ecToken = parameters["token"] {
                self.ecToken = ecToken
            }

            baToken = parameters["ba_token"]
            timestamp = parameters["switch_initiated_time"]
        } else if url.path.contains("cancel") {
            state = .canceled
        } else {
            state = .unknown
        }
    }

    // MARK: - Static Methods

    /// Evaluates whether the url represents a valid PayPal return URL.
    /// - Parameter url: an app switch return URL
    /// - Returns: `true` if the url represents a valid PayPal app switch return
    static func isValid(_ url: URL) -> Bool {
        url.scheme == "https" && (url.path.contains("cancel") || url.path.contains("success"))
    }
}
