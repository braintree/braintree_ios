import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Error details associated with Visa Checkout.
public enum BTVisaCheckoutError: Int, Error, CustomNSError, LocalizedError, Equatable {
    case unknown
    case unsupported
    case integration
    case checkoutUnsuccessful
    case cancelled

    public static var errorDomain: String {
        BTCoreConstants.visaCheckoutErrorDomain
    }
    public var errorCode: String {
        switch self {
        case .unknown:
            return "Failed to parse Visa Checkout card nonce."
        case .unsupported:
            return "Visa Checkout is not enabled for this merchant. Please ensure that Visa Checkout is enabled in the Braintree Control Panel and try again."
        case .integration:
            return "A valid VisaCheckoutResult is required."
        case .checkoutUnsuccessful:
            return "Visa Checkout unsuccessful. Please try again."
        case .cancelled:
            return "Visa Checkout cancelled"
        }
    }
}

