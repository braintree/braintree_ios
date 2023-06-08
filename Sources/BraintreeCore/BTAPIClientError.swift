import Foundation

///  Error codes associated with a API Client.
enum BTAPIClientError: Int, Error, CustomNSError, LocalizedError {

    /// 0. Configuration fetch failed
    case configurationUnavailable

    /// 1. Not authorized
    case notAuthorized

    /// 2. Deallocated BTAPIClient
    case deallocated

    static var errorDomain: String {
        "com.braintreepayments.BTAPIClientErrorDomain"
    }

    var errorCode: Int {
        rawValue
    }

    var errorDescription: String? {
        switch self {
        case .configurationUnavailable:
            return "The operation couldn’t be completed. Unable to fetch remote configuration from Braintree API at this time."

        case .notAuthorized:
            return "Cannot fetch payment method nonces with a tokenization key. This endpoint requires a client token for authorization."

        case .deallocated:
            return "BTAPIClient has been deallocated."
        }
    }
}
