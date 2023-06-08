import Foundation

enum BTJSONError: Error, CustomNSError, LocalizedError {

    /// 0. JSONSerialization failure
    case jsonSerializationFailure
    
    /// 1. Invalid index
    case indexInvalid(Int)
    
    /// 2. Invalid key
    case keyInvalid(String)
    
    static var errorDomain: String {
        "com.braintreepayments.BTJSONErrorDomain"
    }
    
    var errorCode: Int {
        switch self {
        case .jsonSerializationFailure:
            return 0
        case .indexInvalid(_):
            return 1
        case .keyInvalid(_):
            return 2
        }
    }
    
    var errorDescription: String? {
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
