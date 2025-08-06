import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Error details associated with Visa Checkout.
public enum BTVisaCheckoutError: Int, Error, CustomNSError, LocalizedError, Equatable {

    /// 0. Visa Checkout flow was canceled by the user.
    case canceled

    /// 1. Visa Checkout SDK was unsuccessful.
    case checkoutUnsuccessful

    /// 2. Failed to create Visa Checkout card nonce.
    case failedToCreateNonce

    /// 3. Failed to fetch Braintree configuration.
    case fetchConfigurationFailed

    /// 4. A valid VisaCheckoutResult is required.
    case integration

    /// 5. Visa Checkout is disabled in the Braintree Control Panel.
    case disabled

    public var errorCode: Int {
        rawValue
    }

    public var errorDescription: String? {
        switch self {
        case .canceled:
            return "Visa Checkout flow was canceled by the user."
        case .checkoutUnsuccessful:
            return "Visa Checkout unsuccessful. Please try again."
        case .failedToCreateNonce:
            return "Failed to create Visa Checkout card nonce."
        case .fetchConfigurationFailed:
            return "Failed to fetch Braintree configuration."
        case .integration:
            return "A valid VisaCheckoutResult is required."
        case .disabled:
            return "Visa Checkout is not enabled. Please ensure that Visa Checkout is enabled in the Braintree Control Panel and try again."
        }
    }

    // MARK: - Equatable Conformance

    public static func == (lhs: BTVisaCheckoutError, rhs: BTVisaCheckoutError) -> Bool {
        lhs.errorCode == rhs.errorCode
    }
}
