import Foundation

///  Error details associated with PayPal Messaging.
enum BTPayPalMessagingError: Int, Error, CustomNSError, LocalizedError {

    /// 0. Failed to fetch Braintree configuration
    case fetchConfigurationFailed

    /// 1. Could not find PayPal client ID in the Braintree configuration
    case payPalClientIDNotFound

    static var errorDomain: String {
        "com.braintreepayments.BTPayPalMessagingErrorDomain"
    }

    var errorCode: Int {
        rawValue
    }

    var errorDescription: String? {
        switch self {
        case .fetchConfigurationFailed:
            return "Failed to fetch Braintree configuration."
        case .payPalClientIDNotFound:
            return "Could not find PayPal client ID in Braintree configuration."
        }
    }
}
