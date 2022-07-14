import Foundation

enum BTJSONErrorSwift: Error, CustomNSError, LocalizedError {
    
    /// Unknown value
    case indexInvalid(Int)
    
    /// Invalid value
    case keyInvalid(String)
    
    static var errorDomain: String {
        "com.braintreepayments.BTJSONErrorDomain"
    }
    
    var errorCode: Int {
        switch self {
        case .indexInvalid(_):
            return 0
        case .keyInvalid(_):
            return 1
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .indexInvalid(let index):
            return "Attempted to index into a value that is not an array using index \(index)"
        case .keyInvalid(let key):
            return "Attempted to index into a value that is not a dictionary using key \(key)"
        }
    }
}
