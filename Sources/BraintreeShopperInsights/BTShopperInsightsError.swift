import Foundation

public enum BTShopperInsightsError: Int, Error, CustomNSError, LocalizedError, Equatable {
    
    /// 0. A nil body was returned from the payment method request and no error was returned.
    case emptyBodyReturned

    /// 1. Invalid authorization type
    case invalidAuthorization

    public static var errorDomain: String {
        "com.braintreepayments.BTShopperInsightsErrorDomain"
    }
    
    public var errorCode: Int {
        rawValue
    }
    
    public var errorDescription: String? {
        switch self {
        case .emptyBodyReturned:
            return "An empty body was returned from the Eligible Payments API during the request."
        case .invalidAuthorization:
            return "Invalid authorization. This feature can only be used with a client token."
        }
    }
}
