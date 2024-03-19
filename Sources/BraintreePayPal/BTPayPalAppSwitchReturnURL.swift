import Foundation

enum BTPayPalAppSwitchReturnURLState {
    case unknown
    case succeeded
    case canceled
}

/// This class interprets URLs received from the PayPal app via app switch returns.
///
/// PayPal app switch authorization requests should result in success or user-initiated cancelation. These states are communicated in the url.
struct BTPayPalAppSwitchReturnURL {

    /// Initializes a new `BTPayPalAppSwitchReturnURL`
    /// - Parameter url: an incoming app switch url
    init?(url: URL) {
        // TODO: implement init based on return URL
    }

    // MARK: - Static Methods

    /// Evaluates whether the url represents a valid PayPal return URL.
    /// - Parameter url: an app switch return URL
    /// - Returns: `true` if the url represents a valid PayPal app switch return
    static func isValid(_ url: URL) -> Bool {
        url.scheme == "https" && (url.path.contains("cancel") || url.path.contains("success"))
    }
}
