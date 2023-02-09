import Foundation

/// Error codes associated with Apple Pay.
enum BTApplePayError: Int, Error, CustomNSError, LocalizedError {

    /// Unknown error
    case unknown

    /// Apple Pay is disabled in the Braintree Control Panel
    case unsupported

    /// No Apple Pay Card data was returned
    case noApplePayCardsReturned

    /// Unable to create BTApplePayCardNonce
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
            // TODO: needs test
        case .noApplePayCardsReturned:
            return "No Apple Pay Card data was returned. Please contact support."
            //TODO: needs test
        case .failedToCreateNonce:
            return "Unable to create BTApplePayCardNonce. Either body did not contain applePayCards data or contents could not be parsed."
        }
    }
}
