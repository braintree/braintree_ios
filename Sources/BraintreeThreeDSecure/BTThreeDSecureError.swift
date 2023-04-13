import Foundation

enum BTThreeDSecureError: Error, CustomNSError, LocalizedError {

    /// Unknown error
    case unknown

    /// 3D Secure failed during the backend card lookup phase; please retry
    case failedLookup([String: Any])

    /// 3D Secure failed during the user-facing authentication phase; please retry
    case failedAuthentication(String)

    /// 3D Secure was not configured correctly
    case configuration(String)
    
    /// A body was not returned from the API during the request.
    case noBodyReturned

    /// User canceled the 3DS 2 flow.
    case canceled

    /// The BTAPIClient was invalid or missing
    case invalidAPIClient

    /// Cannot cast BTPaymentFlowRequest to BTThreeDSecureRequest
    case cannotCastRequest

    /// The request could not be serialized.
    case jsonSerializationFailure

    static var errorDomain: String {
        "com.braintreepayments.BTThreeDSecureFlowErrorDomain"
    }

    var errorCode: Int {
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
        case .cannotCastRequest:
            return 7
        case .jsonSerializationFailure:
            return 8
        }
    }

    var errorUserInfo: [String : Any] {
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
        case .cannotCastRequest:
            return [NSLocalizedDescriptionKey: "Cannot cast BTPaymentFlowRequest to BTThreeDSecureRequest"]
        case .jsonSerializationFailure:
            return [NSLocalizedDescriptionKey: "The request could not be serialized."]
        }
    }
}
