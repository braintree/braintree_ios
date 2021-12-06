import Foundation

/**
 Error codes associated with American Express.
 */
enum BTAmericanExpressError: Error, CustomNSError, LocalizedError {
    /// Unknown error
    case unknown
    
    /// Empty response
    case emptyResponse
    
    static var errorDomain: String {
        "com.braintreepayments.BTAmericanExpressErrorDomain"
    }
    
    var errorCode: Int {
        switch self {
        case .unknown:
            return 0

        case .emptyResponse:
            return 1
        }
    }

    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown error"

        case .emptyResponse:
            return "Response was empty"
        }
    }
}
