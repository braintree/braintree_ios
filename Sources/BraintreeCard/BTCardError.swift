import Foundation

// Error codes associated with cards
public enum BTCardError: Error, CustomNSError, LocalizedError, Equatable {

    /// 0. Unknown error
    case unknown

    /// 1. Braintree SDK is integrated incorrectly
    case integration

    /// 2. Customer provided invalid input
    case customerInputInvalid([String: Any])

    /// 3. Card already exists as a saved payment method
    case cardAlreadyExists([String: Any])
    
    /// 4. Failed to fetch Braintree configuration
    case fetchConfigurationFailed

    public static var errorDomain: String {
        "com.braintreepayments.BTCardClientErrorDomain"
    }

    public var errorCode: Int {
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

    // swiftlint:disable line_length
    public var errorUserInfo: [String: Any] {
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
    // swiftlint:enable line_length

    // MARK: - Equatable Conformance

    public static func == (lhs: BTCardError, rhs: BTCardError) -> Bool {
        lhs.errorCode == rhs.errorCode
    }
}
