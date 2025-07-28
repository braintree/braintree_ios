import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Error details associated with Visa Checkout.
public enum BTVisaCheckoutError: Error, CustomNSError, LocalizedError, Equatable {

    /// 0. Unknown error.
    case unknown

    /// 1. Visa Checkout is disabled in the Braintree Control Panel.
    case unsupported

    /// 2. Braintree SDK is integrated incorrectly.
    case integration

    /// 3. Visa Checkout SDK responded with an unsuccessful status code.
    case checkoutUnsuccessful

    /// 4. Visa Checkout was cancelled by the user.
    case canceled

    public var errorCode: Int {
        switch self {
        case .unknown:
            return 0
        case .unsupported:
            return 1
        case .integration:
            return 2
        case .checkoutUnsuccessful:
            return 3
        case .canceled:
            return 4
        }
    }

    public var errorDescription: String? {
        switch self {
        case .unknown:
            return "Failed to parse Visa Checkout card nonce."
        case .unsupported:
            return "Visa Checkout is not enabled. Please ensure that Visa Checkout is enabled in the Braintree Control Panel and try again."
        case .integration:
            return "VisaCheckout is integrated incorrectly."
        case .checkoutUnsuccessful:
            return "Visa Checkout unsuccessful. Please try again."
        case .canceled:
            return "Visa Checkout cancelled."
        }
    }

    // MARK: - Equatable Conformance

    public static func == (lhs: BTVisaCheckoutError, rhs: BTVisaCheckoutError) -> Bool {
        lhs.errorCode == rhs.errorCode
    }
}
