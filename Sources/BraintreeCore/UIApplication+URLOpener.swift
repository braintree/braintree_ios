import UIKit

/// :nodoc: This protocol is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
///
/// Used to mock `UIApplication`.
@_documentation(visibility: private)
public protocol URLOpener {

    func canOpenURL(_ url: URL) -> Bool
    func open(_ url: URL, completionHandler completion: ((Bool) -> Void)?)
    func isPayPalAppInstalled() -> Bool
    func isVenmoAppInstalled() -> Bool
}

extension UIApplication: URLOpener {

    /// :nodoc: This method is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// Indicates whether the Venmo App is installed.
    @_documentation(visibility: private)
    public func isVenmoAppInstalled() -> Bool {
        guard let venmoURL = URL(string: "\(BTCoreConstants.venmoURLScheme)://") else {
            return false
        }
        return canOpenURL(venmoURL)
    }

    /// :nodoc: This method is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// Indicates whether the PayPal App is installed.
    @_documentation(visibility: private)
    public func isPayPalAppInstalled() -> Bool {
        guard let payPalURL = URL(string: "\(BTCoreConstants.payPalURLScheme)://") else {
            return false
        }
        return canOpenURL(payPalURL)
    }

    // TODO: once Xcode 16 is the minimum supported version remove this method and update the protocol to the default open signature from UIApplication
    /// :nodoc: This method is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// Indicates whether the PayPal App is installed.
    @_documentation(visibility: private)
    public func open(_ url: URL, completionHandler completion: ((Bool) -> Void)?) {
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
}
