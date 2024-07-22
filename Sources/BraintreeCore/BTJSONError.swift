import Foundation

public enum BTJSONError: Error, CustomNSError, LocalizedError, Equatable {

    /// 0. JSONSerialization failure
    case jsonSerializationFailure
    
    /// 1. Invalid index
    case indexInvalid(Int)
    
    /// 2. Invalid key
    case keyInvalid(String)
    
    public static var errorDomain: String {
        "com.braintreepayments.BTJSONErrorDomain"
    }
    
    public var errorCode: Int {
        switch self {
        case .jsonSerializationFailure:
            return 0
        case .indexInvalid:
            return 1
        case .keyInvalid:
            return 2
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .jsonSerializationFailure:
            return "Failed to serialize JSON data in initilizer"
        case .indexInvalid(let index):
            return "Attempted to index into a value that is not an array using index \(index)"
        case .keyInvalid(let key):
            return "Attempted to index into a value that is not a dictionary using key \(key)"
        }
    }
}
