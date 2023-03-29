import Foundation

enum BTThreeDSecureError: Error, CustomNSError, LocalizedError {

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

    case authenticationResponse(String)

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
        case .authenticationResponse:
            return 5
        }
    }

    var errorDescription: String? {
        switch self {
        case .unknown:
            return "An unknown error occurred. Please contact support."
        case .failedLookup:
            return "" // TODO: will be implemented when BTPaymentFlowClient+ThreeDSecure is converted to Swift
        case .failedAuthentication:
            return "Tokenized card nonce is required."
        case .configuration:
            return "Merchant is not configured for 3SD 2."
        case .noBodyReturned:
            return "A body was not returned from the API during the request."
        case .authenticationResponse(let description):
            return description
        }
    }
}
