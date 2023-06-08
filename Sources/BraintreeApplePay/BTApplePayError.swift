import Foundation

/// Error codes associated with Apple Pay.
enum BTApplePayError: Int, Error, CustomNSError, LocalizedError {

    /// 0. Unknown error
    case unknown

    /// 1. Apple Pay is disabled in the Braintree Control Panel
    case unsupported

    /// 2. No Apple Pay Card data was returned
    case noApplePayCardsReturned

    /// 3. Unable to create BTApplePayCardNonce
    case failedToCreateNonce

    static var errorDomain: String {
        "com.braintreepayments.BTApplePayErrorDomain"
    }

    var errorCode: Int {
        rawValue
    }

    var errorDescription: String? {
        switch self {
        case .unknown:
            return ""
        case .unsupported:
            return "Apple Pay is not enabled for this merchant. Please ensure that Apple Pay is enabled in the control panel and then try saving an Apple Pay payment method again."
        case .noApplePayCardsReturned:
            return "No Apple Pay Card data was returned. Please contact support."
        case .failedToCreateNonce:
            return "Unable to create BTApplePayCardNonce. Either body did not contain applePayCards data or contents could not be parsed."
        }
    }
}
