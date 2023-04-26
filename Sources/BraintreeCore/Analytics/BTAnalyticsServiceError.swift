import Foundation

///  Error codes associated with a API Client.
enum BTAnalyticsServiceError: Int, Error, CustomNSError, LocalizedError {

    /// 0. Missing analytics URL
    case missingAnalyticsURL // TODO: - remove or replace

    /// 0. Invalid API client
    case invalidAPIClient

    static var errorDomain: String {
        "com.braintreepayments.BTAnalyticsServiceErrorDomain"
    }

    var errorCode: Int {
        rawValue
    }

    var errorDescription: String? {
        switch self {
        case .missingAnalyticsURL:
            return "Analytics is disabled in remote configuration"
        case .invalidAPIClient:
            return "API client must have client token or tokenization key"
        }
    }
}
