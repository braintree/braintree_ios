import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Error details associated with Visa Checkout.
public enum BTVisaCheckoutError: Error, CustomNSError, LocalizedError, Equatable {

    /// 0. Visa Checkout was cancelled by the user.
    case canceled

    /// 1. Visa Checkout SDK responded with an unsuccessful status code.
    case checkoutUnsuccessful

    /// 2. Failed to create Visa Checkout card nonce.
    case failedToCreateNonce

    /// 3.
    case fetchConfigurationFailed

    /// 4. Braintree SDK is integrated incorrectly.
    case integration

    /// 5. Visa Checkout is disabled in the Braintree Control Panel.
    case unsupported

    public var errorCode: Int {
        switch self {
        case .canceled:
            return 1
        case .checkoutUnsuccessful:
            return 2
        case .failedToCreateNonce:
            return 3
        case .fetchConfigurationFailed:
            return 4
        case .integration:
            return 5
        case .unsupported:
            return 6
        }
    }

    public var errorDescription: String? {
        switch self {
        case .canceled:
            return "Visa Checkout cancelled."
        case .checkoutUnsuccessful:
            return "Visa Checkout unsuccessful. Please try again."
        case .failedToCreateNonce:
            return "Failed to create Visa Checkout card nonce."
        case .fetchConfigurationFailed:
            return "Failed to fetch Braintree configuration."
        case .integration:
            return "VisaCheckout is integrated incorrectly."
        case .unsupported:
            return "Visa Checkout is not enabled. Please ensure that Visa Checkout is enabled in the Braintree Control Panel and try again."
        }
    }

    // MARK: - Equatable Conformance

    public static func == (lhs: BTVisaCheckoutError, rhs: BTVisaCheckoutError) -> Bool {
        lhs.errorCode == rhs.errorCode
    }
}
