import Foundation

public enum BTThreeDSecureError: Error, CustomNSError, LocalizedError, Equatable {

    /// 0. Unknown error
    case unknown

    /// 1. 3D Secure failed during the backend card lookup phase; please retry
    case failedLookup([String: Any])

    /// 2. 3D Secure failed during the user-facing authentication phase; please retry
    case failedAuthentication(String)

    /// 3. 3D Secure was not configured correctly
    case configuration(String)
    
    /// 4. A body was not returned from the API during the request.
    case noBodyReturned

    /// 5. User canceled the 3DS 2 flow.
    case canceled

    /// 6. The BTAPIClient was invalid or missing
    case invalidAPIClient

    /// 7. The request could not be serialized.
    case jsonSerializationFailure

    /// 8. Deallocated BTThreeDSecureClient
    case deallocated

    /// 9. 3D Secure was idle and exceeded timout limit
    case exceededTimeoutLimit

    public static var errorDomain: String {
        "com.braintreepayments.BTThreeDSecureFlowErrorDomain"
    }

    public var errorCode: Int {
        switch self {
        case .unknown:
            return 0
        case .failedLookup:
            return 1
        case .failedAuthentication:
            return 2
        case .configuration:
            return 3
        case .noBodyReturned:
            return 4
        case .canceled:
            return 5
        case .invalidAPIClient:
            return 6
        case .jsonSerializationFailure:
            return 7
        case .deallocated:
            return 8
        case .exceededTimeoutLimit:
            return 9
        }
    }

    public var errorUserInfo: [String: Any] {
        switch self {
        case .unknown:
            return [NSLocalizedDescriptionKey: "An unknown error occurred. Please contact support."]
        case .failedLookup(let errorDictionary):
            return errorDictionary
        case .failedAuthentication(let description):
            return [NSLocalizedDescriptionKey: description]
        case .configuration(let description):
            return [NSLocalizedDescriptionKey: description]
        case .noBodyReturned:
            return [NSLocalizedDescriptionKey: "A body was not returned from the API during the request."]
        case .canceled:
            return [NSLocalizedDescriptionKey: "The user canceled the 3DS 2 flow."]
        case .invalidAPIClient:
            return [NSLocalizedDescriptionKey: "The BTAPIClient was invalid or missing."]
        case .jsonSerializationFailure:
            return [NSLocalizedDescriptionKey: "The request could not be serialized."]
        case .deallocated:
            return [NSLocalizedDescriptionKey: "BTThreeDSecureClient has been deallocated."]
        case .exceededTimeoutLimit:
            return [NSLocalizedDescriptionKey: "User exceeded timeout limit."]
        }
    }

    // MARK: - Equatable Conformance

    public static func == (lhs: BTThreeDSecureError, rhs: BTThreeDSecureError) -> Bool {
        lhs.errorCode == rhs.errorCode
    }
}
