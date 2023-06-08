import Foundation

///  Error details associated with Braintree Data Collector.
enum BTDataCollectorError: Int, Error, CustomNSError, LocalizedError {

    /// 0. Unknown error
    case unknown
    
    /// 1. The request could not be serialized.
    case jsonSerializationFailure
    
    /// 2. The device data could not be encoded.
    case encodingFailure

    static var errorDomain: String {
        "com.braintreepayments.BTDataCollectorErrorDomain"
    }
    
    var errorCode: Int {
        rawValue
    }

    var errorDescription: String? {
        switch self {
        case .unknown:
            return "An unknown error occurred. Please contact support."

        case .jsonSerializationFailure:
            return "The request could not be serialized."

        case .encodingFailure:
            return "The device data could not be encoded."
        }
    }
}
