import Foundation

///  Error details associated with Braintree Data Collector.
public enum BTDataCollectorError: Int, Error, CustomNSError, LocalizedError, Equatable {

    /// 0. Unknown error
    case unknown
    
    /// 1. The request could not be serialized.
    case jsonSerializationFailure
    
    /// 2. The device data could not be encoded.
    case encodingFailure

    /// 3. Magnes SDK failed to submit device data.
    case callbackSubmitError

    /// 4. Magnes SDK timed out while submitting device data.
    case callbackSubmitTimeout

    public static var errorDomain: String {
        "com.braintreepayments.BTDataCollectorErrorDomain"
    }
    
    public var errorCode: Int {
        rawValue
    }

    public var errorDescription: String? {
        switch self {
        case .unknown:
            return "An unknown error occurred. Please contact support."

        case .jsonSerializationFailure:
            return "The request could not be serialized."

        case .encodingFailure:
            return "The device data could not be encoded."

        case .callbackSubmitError:
            return "Failed to submit device data."

        case .callbackSubmitTimeout:
            return "Timed out while submitting device data."
        }
    }
}
