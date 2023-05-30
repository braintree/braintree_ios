import Foundation

// Error codes associated with cards
enum BTCardError: Error, CustomNSError, LocalizedError {

    /// Unknown error
    case unknown

    /// Braintree SDK is integrated incorrectly
    case integration

    /// Customer provided invalid input
    case customerInputInvalid([String: Any])

    /// Card already exists as a saved payment method
    case cardAlreadyExists([String: Any])
    
    /// Failed to fetch Braintree configuration
    case fetchConfigurationFailed

    static var errorDomain: String {
        "com.braintreepayments.BTCardClientErrorDomain"
    }

    var errorCode: Int {
        switch self {
        case .unknown:
            return 0
        case .integration:
            return 1
        case .customerInputInvalid:
            return 2
        case .cardAlreadyExists:
            return 3
        case .fetchConfigurationFailed:
            return 4
        }
    }

    var errorUserInfo: [String: Any] {
        switch self {
        case .unknown:
            return [NSLocalizedDescriptionKey: "An unknown error occurred. Please contact support."]
        case .integration:
            return [NSLocalizedDescriptionKey: "BTCardClient tokenization failed because a merchant account ID is required when authenticationInsightRequested is true."]
        case .customerInputInvalid(let errorDictionary):
            return errorDictionary
        case .cardAlreadyExists(let errorDictionary):
            return errorDictionary
        case .fetchConfigurationFailed:
            return [NSLocalizedDescriptionKey: "Failed to fetch Braintree configuration."]
        }
    }
}
