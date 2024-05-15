import Foundation

///  Error details associated with PayPal Messaging.
/// - Warning: This module is in beta. It's public API may change or be removed in future releases.
public enum BTPayPalMessagingError: Int, Error, CustomNSError, LocalizedError, Equatable {

    /// 0. Failed to fetch Braintree configuration
    case fetchConfigurationFailed

    /// 1. Could not find PayPal client ID in the Braintree configuration
    case payPalClientIDNotFound

    public static var errorDomain: String {
        "com.braintreepayments.BTPayPalMessagingErrorDomain"
    }

    public var errorCode: Int {
        rawValue
    }

    public var errorDescription: String? {
        switch self {
        case .fetchConfigurationFailed:
            return "Failed to fetch Braintree configuration."
        case .payPalClientIDNotFound:
            return "Could not find PayPal client ID in Braintree configuration."
        }
    }
}
