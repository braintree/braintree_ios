import Foundation

/// Error codes associated with Apple Pay.
public enum BTApplePayError: Int, Error, CustomNSError, LocalizedError, Equatable {

    /// 0. Unknown error
    case unknown

    /// 1. Apple Pay is disabled in the Braintree Control Panel
    case unsupported

    /// 2. No Apple Pay Card data was returned
    case noApplePayCardsReturned

    /// 3. Unable to create BTApplePayCardNonce
    case failedToCreateNonce

    public static var errorDomain: String {
        "com.braintreepayments.BTApplePayErrorDomain"
    }

    public var errorCode: Int {
        rawValue
    }

    public var errorDescription: String? {
        switch self {
        case .unknown:
            return ""
        case .unsupported:
            // swiftlint:disable line_length
            return "Apple Pay is not enabled for this merchant. Please ensure that Apple Pay is enabled in the control panel and then try saving an Apple Pay payment method again."
            // swiftlint:enable line_length
        case .noApplePayCardsReturned:
            return "No Apple Pay Card data was returned. Please contact support."
        case .failedToCreateNonce:
            return "Unable to create BTApplePayCardNonce. Either body did not contain applePayCards data or contents could not be parsed."
        }
    }
}
