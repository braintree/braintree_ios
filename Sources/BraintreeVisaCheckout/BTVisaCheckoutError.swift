import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Error details associated with Visa Checkout.
public enum BTVisaCheckoutError: Int, Error, CustomNSError, LocalizedError, Equatable {

    /// 0. Unknown error.
    case unknown

    /// 1. Visa Checkout is disabled in the Braintree Control Panel.
    case unsupported

    /// 2. Braintree SDK is integrated incorrectly.
    case integration

    /// 3. Visa Checkout SDK responded with an unsuccessful status code.
    case checkoutUnsuccessful

    /// 4. Visa Checkout was cancelled by the user.
    case cancelled

    public var errorCode: String {
        switch self {
        case .unknown:
            return "Failed to parse Visa Checkout card nonce."
        case .unsupported:
            return "Visa Checkout is not enabled. Please ensure that Visa Checkout is enabled in the Braintree Control Panel and try again."
        case .integration:
            return "A valid VisaCheckoutResult is required."
        case .checkoutUnsuccessful:
            return "Visa Checkout unsuccessful. Please try again."
        case .cancelled:
            return "Visa Checkout cancelled"
        }
    }
}
