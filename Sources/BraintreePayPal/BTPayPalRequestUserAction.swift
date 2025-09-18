///  The call-to-action in the PayPal flow.
///
///  - Note: By default the final button will show the localized word for "Continue" for Checkout requests or
///  "Save and Continue" for Vault requests and implies that the final amount billed is not yet known.
///
///  Setting the `BTPayPalCheckoutRequest.userAction` to `.payNow` changes
///  the button text to "Pay Now", conveying to the user that billing will take place immediately.
///
///  Setting the `BTPayPalVaultRequest.userAction` to `.setupNow` changes the button text to "Setup Now", conveying to
///  the user that the funding instrument will be set up for future payments.
@objc public enum BTPayPalRequestUserAction: Int {
    @available(*, deprecated, message: "Use a specific user action like `.payNow`, `.continue`, or `.setupNow`. `.none` will be removed.")
    case none

    /// Pay Now - this value can only be passed for the `BTPayPalCheckoutRequest`
    case payNow
    
    /// Setup Now - this value can only be passed for the `BTPayPalVaultRequest`
    case setupNow

    /// Continue
    case `continue`

    /// Reserved for unknown or unsupported values.
    case unknown

    var stringValue: String {
        switch self {
        case .payNow:
            return "commit"
        case .setupNow:
            return "setup_now"
        default:
            return ""
        }
    }

    var analyticsValue: String {
        switch self {
        case .payNow:
            return "pay"
        case .setupNow:
            return "setup_now"
        case .continue, .none:
            return "continue"
        case .unknown:
            return "none"
        }
    }
}
