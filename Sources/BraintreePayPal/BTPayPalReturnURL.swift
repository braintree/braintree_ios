import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

enum BTPayPalReturnURLState {
    case unknownPath
    case succeeded
    case canceled
}

/// This class interprets URLs received from the PayPal app via app switch returns and web returns via ASWebAuthenticationSession.
///
/// PayPal app switch and ASWebAuthenticationSession authorization requests should result in success or user-initiated cancelation. These states are communicated in the url.
struct BTPayPalReturnURL {

    /// The overall status of the app switch - success, cancelation, or an unknown path
    var state: BTPayPalReturnURLState = .unknownPath

    /// Initializes a new `BTPayPalReturnURL`
    /// - Parameter url: an incoming app switch or ASWebAuthenticationSession url
    init?(_ redirectType: PayPalRedirectType) {
        switch redirectType {
        case .payPalApp(let url), .webBrowser(let url):
            if url.path.contains("success") {
                state = .succeeded
            } else if url.path.contains("cancel") {
                state = .canceled
            } else {
                state = .unknownPath
            }
        }
    }

    // MARK: - Static Methods

    /// Evaluates whether the url represents a valid PayPal return URL.
    /// - Parameter url: an app switch or ASWebAuthenticationSession return URL
    /// - Returns: `true` if the url represents a valid PayPal app switch return
    static func isValid(_ url: URL, fallbackUrlScheme: String?) -> Bool {
        let isValidScheme = url.scheme == "https" || url.scheme == fallbackUrlScheme
        let containsAppSwitchPath = url.path.contains("braintreeAppSwitchPayPal")
        let containsExpectedPath = url.path.contains("cancel") || url.path.contains("success")
        let isValidAppSwitchURL = isValidScheme && containsAppSwitchPath && containsExpectedPath
        
        return isValidAppSwitchURL
    }

    static func isValidURLAction(url: URL, didPayPalServerAttemptAppSwitch: Bool) -> Bool {
        guard let host = url.host, let scheme = url.scheme, !scheme.isEmpty else {
            return false
        }

        var hostAndPath = host
            .appending(url.path)
            .components(separatedBy: "/")
            .dropLast(1) // remove the action (`success`, `cancel`, etc)
            .joined(separator: "/")

        if !hostAndPath.isEmpty {
            hostAndPath.append("/")
        }

        /// If we are using the deeplink/ASWeb based PayPal flow we want to check that the host and path matches
        /// the static callbackURLHostAndPath. For the app switch flow we do not care about this check.
        if hostAndPath != BTPayPalRequest.callbackURLHostAndPath && !didPayPalServerAttemptAppSwitch {
            return false
        }

        guard
            let action = action(from: url),
            let query = url.query,
            !query.isEmpty,
            !action.isEmpty,
            ["success", "cancel", "authenticate"].contains(action)
        else {
            return false
        }

        return true
    }

    static func action(from url: URL) -> String? {
        guard let action = url.lastPathComponent.components(separatedBy: "?").first, !action.isEmpty else {
            return url.host
        }

        return action
    }
}
