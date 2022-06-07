import Foundation

///  Error details associated with Braintree Data Collector.
enum BTDataCollectorError: Error, CustomNSError, LocalizedError {

    /// Unknown error
    case unknown

    /// The Kount merchant ID was invalid
    case noKountMerchantID
    
    /// The request could not be serialized.
    case jsonSerializationFailure
    
    /// The device data could not be encoded.
    case encodingFailure

    static var errorDomain: String {
        "com.braintreepayments.BTDataCollectorErrorDomain"
    }
    
    var errorCode: Int {
        switch self {
        case .unknown:
            return 0

        case .noKountMerchantID:
            return 1

        case .jsonSerializationFailure:
            return 2

        case .encodingFailure:
            return 3
        }
    }

    var errorDescription: String? {
        switch self {
        case .unknown:
            return "An unknown error occurred. Please contact support."

        case .noKountMerchantID:
            return "The Kount merchant ID was invalid. Please contact support."

        case .jsonSerializationFailure:
            return "The request could not be serialized."

        case .encodingFailure:
            return "The device data could not be encoded."
        }
    }
}
