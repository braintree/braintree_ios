import Foundation

// Error codes associated with cards
enum BTCardError: Error, CustomNSError, LocalizedError {

    /// Unknown error
    case unknown

    /// Braintree SDK is integrated incorrectly
    case integration

    /// Payment option (e.g. UnionPay) is not enabled for this merchant account
    case paymentOptionNotEnabled

    /// Customer provided invalid input
    case customerInputInvalid([String: Any])

    /// Card already exists as a saved payment method
    case cardAlreadyExists([String: Any])

    static var errorDomain: String {
        "com.braintreepayments.BTCardClientErrorDomain"
    }

    var errorCode: Int {
        switch self {
        case .unknown:
            return 0
        case .integration:
            return 1
        case .paymentOptionNotEnabled:
            return 2
        case .customerInputInvalid:
            return 3
        case .cardAlreadyExists:
            return 4
        }
    }

    var errorUserInfo: [String : Any] {
        switch self {
        case .unknown:
            return [:]
        case .integration:
            return [:]
        case .paymentOptionNotEnabled:
            return [:]
        case .customerInputInvalid(let errorDictionary):
            return errorDictionary
        case .cardAlreadyExists(let errorDictionary):
            return errorDictionary
        }
    }
}
