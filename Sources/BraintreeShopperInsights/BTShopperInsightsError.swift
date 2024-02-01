import Foundation

public enum BTShopperInsightsError: Int, Error, CustomNSError, LocalizedError, Equatable {
    
    /// 1. A nil body was returned from the payment method request and no error was returned.
    case emptyBodyReturned
    
    public static var errorDomain: String {
        "com.braintreepayments.BTShopperInsightsErrorDomain"
    }
    
    public var errorCode: Int {
        rawValue
    }
    
    public var errorDescription: String? {
        switch self {
        case .emptyBodyReturned:
            "An empty body was returned from the Payments Ready API during the request."
        }
    }
}
