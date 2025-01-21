import Foundation

/// Use this option to specify the PayPal page to display when a user lands on the PayPal site to complete the payment.
@objc public enum BTPayPalRequestLandingPageType: Int {

    /// Default
    case none // Obj-C enums cannot be nil; this default option is used to make `landingPageType` optional for merchants

    /// Login
    case login

    /// Billing
    case billing

    var stringValue: String? {
        switch self {
        case .login:
            return "login"

        case .billing:
            return "billing"

        default:
            return nil
        }
    }
}
