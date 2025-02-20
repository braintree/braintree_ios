import Foundation

///  Error codes associated with a API Client.
public enum BTAPIClientError: Error, CustomNSError, LocalizedError, Equatable {

    /// 0. Configuration fetch failed
    case configurationUnavailable

    /// 1. Not authorized
    case notAuthorized

    /// 2. Deallocated BTAPIClient
    case deallocated
    
    /// 3. Failed to base64 encode an authorizationFingerprint or tokenizationKey, when used as a cacheKey
    case failedBase64Encoding
    
    /// 4. Invalid authorization
    case invalidAuthorization(String)

    public static var errorDomain: String {
        "com.braintreepayments.BTAPIClientErrorDomain"
    }

    public var errorCode: Int {
        switch self {
        case .configurationUnavailable:
            return 0
        case .notAuthorized:
            return 1
        case .deallocated:
            return 2
        case .failedBase64Encoding:
            return 3
        case .invalidAuthorization:
            return 4
        }
    }

    public var errorDescription: String? {
        switch self {
        case .configurationUnavailable:
            return "The operation couldn’t be completed. Unable to fetch remote configuration from Braintree API at this time."

        case .notAuthorized:
            return "Cannot fetch payment method nonces with a tokenization key. This endpoint requires a client token for authorization."

        case .deallocated:
            return "BTAPIClient has been deallocated."
            
        case .failedBase64Encoding:
            return "Unable to base64 encode the authorization string."
            
        case .invalidAuthorization(let authorization):
            return "Invalid authorization provided: \(authorization)."

        }
    }
}
