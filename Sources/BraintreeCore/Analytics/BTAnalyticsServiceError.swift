import Foundation

///  Error codes associated with a API Client.
public enum BTAnalyticsServiceError: Int, Error, CustomNSError, LocalizedError, Equatable {

    /// 0. Invalid API client
    case invalidAPIClient

    public static var errorDomain: String {
        "com.braintreepayments.BTAnalyticsServiceErrorDomain"
    }

    public var errorCode: Int {
        rawValue
    }

    public var errorDescription: String? {
        switch self {
        case .invalidAPIClient:
            return "API client must have client token or tokenization key"
        }
    }
}
