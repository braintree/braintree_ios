import UIKit

extension UIApplication {

    static func isVenmoAppInstalled() -> Bool {
        guard let venmoURL = URL(string: "\(BTCoreConstants.venmoURLScheme)://") else {
            return false
        }
        return shared.canOpenURL(venmoURL)
    }

    /// :nodoc: This method is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// Indicates whether the PayPal App is installed.
    @_documentation(visibility: private)
    public static func isPayPalAppInstalled() -> Bool {
        guard let payPalURL = URL(string: "\(BTCoreConstants.payPalURLScheme)://") else {
            return false
        }
        return shared.canOpenURL(payPalURL)
    }
}
