import Foundation

enum BTThreeDSecureError: Int, Error, CustomNSError, LocalizedError {

    /// Unknown error
    case unknown

    /// 3D Secure failed during the backend card lookup phase; please retry
    case failedLookup

    /// 3D Secure failed during the user-facing authentication phase; please retry
    case failedAuthentication

    /// 3D Secure was not configured correctly
    case configuration

    /// A body was not returned from the API during the request.
    case noBodyReturned

    static var errorDomain: String {
        "com.braintreepayments.BTThreeDSecureFlowErrorDomain"
    }

    var errorCode: Int {
        rawValue
    }

    // TODO: errors
    var errorDescription: String? {
        switch self {
        case .unknown:
            return ""
        case .failedLookup:
            return ""
        case .failedAuthentication:
            return "Tokenized card nonce is required"
        case .configuration:
            return "Merchant is not configured for 3SD 2."
        case .noBodyReturned:
            return "A body was not returned from the API during the request."
        }
    }
}
