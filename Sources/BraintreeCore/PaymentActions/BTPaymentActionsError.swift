import Foundation

public enum BTPaymentActionsError: Error, CustomNSError, LocalizedError, Equatable {
    
    /// 0. Unknown error
    case unknown
    
    /// 1. Customer provided invalid input
    case customerInputInvalid([String: Any])
    
    public static var errorDomain: String {
        "com.braintreepayments.BTPaymentActionsErrorDomain"
    }
    
    public var errorCode: Int {
        switch self {
        case .unknown:
            return 0
        case .customerInputInvalid:
            return 1
        }
    }
    
    public var errorUserInfo: [String: Any] {
        switch self {
        case .unknown:
            return [NSLocalizedDescriptionKey: "An unknown error occurred. Please contact support."]
            
        case .customerInputInvalid(let errorDictionary):
            return errorDictionary
        }
    }
    
    public static func == (lhs: BTPaymentActionsError, rhs: BTPaymentActionsError) -> Bool {
        lhs.errorCode == rhs.errorCode
    }
}
