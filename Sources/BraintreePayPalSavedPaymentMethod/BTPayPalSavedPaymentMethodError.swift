import Foundation

enum BTPayPalSavedPaymentMethodError: Int, Error, CustomNSError, LocalizedError, Equatable {

    /// 0. The authorization used to initialize the client is not a client token.
    case invalidAuthorization

    /// 1. The client token does not carry a payment method ID JWT.
    case missingPaymentMethodIDJWT

    /// 2. An order ID was not provided for a `fiFromApprovedCheckout` fetch.
    case missingOrderID

    /// 3. A nil body was returned from the funding instrument details request and no error was returned.
    case emptyBodyReturned

    /// 4. The funding instrument details could not be parsed from the response.
    case failedToParseSummary

    /// 5. PayPal returned no Pay Later message to display for this buyer.
    case missingPreferredMessage

    static var errorDomain: String {
        "com.braintreepayments.BTPayPalSavedPaymentMethodErrorDomain"
    }

    var errorCode: Int {
        rawValue
    }

    var errorDescription: String? {
        switch self {
        case .invalidAuthorization:
            return "Invalid authorization. This feature can only be used with a client token."
        case .missingPaymentMethodIDJWT:
            return "The client token is missing a payment method ID JWT. Generate it with a payment method ID."
        case .missingOrderID:
            return "An order ID is required to fetch the funding instrument selected on an approved checkout."
        case .emptyBodyReturned:
            return "An empty body was returned from the funding instrument details request."
        case .failedToParseSummary:
            return "Unable to parse the funding instrument details from the response."
        case .missingPreferredMessage:
            return "No Pay Later message was returned for this buyer."
        }
    }
}
