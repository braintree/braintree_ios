import Foundation

enum BTThreeDSecureError: Error, CustomNSError, LocalizedError {

    /// Unknown error
    case unknown

    /// 3D Secure failed during the backend card lookup phase; please retry
    case failedLookup

    /// 3D Secure failed during the user-facing authentication phase; please retry
    case failedAuthentication(String)

    /// 3D Secure was not configured correctly
    case configuration(String)

    /// A body was not returned from the API during the request.
    case noBodyReturned

    /// The BTAPIClient was invalid or missing
    case invalidAPIClient

    /// Cannot cast BTPaymentFlowRequest to BTThreeDSecureRequest
    case cannotCastRequest

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
        case .invalidAPIClient:
            return 5
        case .cannotCastRequest:
            return 6
        }
    }

    var errorDescription: String? {
        switch self {
        case .unknown:
            return "An unknown error occurred. Please contact support."
        case .failedLookup:
            return "" // TODO: will be implemented when BTPaymentFlowClient+ThreeDSecure is converted to Swift
        case .failedAuthentication(let description):
            return description
        case .configuration(let description):
            return description
        case .noBodyReturned:
            return "A body was not returned from the API during the request."
        case .invalidAPIClient:
            return "The BTAPIClient was invalid or missing."
        case .cannotCastRequest:
            return "Cannot cast BTPaymentFlowRequest to BTThreeDSecureRequest"
        }
    }
}
