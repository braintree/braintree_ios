import Foundation

///  Error details associated with American Express.
enum BTAmericanExpressError: Int, Error, CustomNSError, LocalizedError {

    /// 0. Unknown error
    case unknown

    /// 1. An API response was received with missing rewards data
    case noRewardsData

    /// 2. Deallocated BTAmericanExpressClient
    case deallocated

    static var errorDomain: String {
        "com.braintreepayments.BTAmericanExpressErrorDomain"
    }
    
    var errorCode: Int {
        switch self {
        case .unknown:
            return BTAmericanExpressErrorCode.unknown.rawValue
        case .noRewardsData:
            return BTAmericanExpressErrorCode.noRewardsData.rawValue
        case .deallocated:
            return BTAmericanExpressErrorCode.deallocated.rawValue
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "An unknown error occurred. Please contact support."

        case .noRewardsData:
            return "No American Express Rewards data was returned. Please contact support."

        case .deallocated:
            return "BTAmericanExpressClient has been deallocated."
        }
    }
}


/// Public for merchants to reference (accessible in both Swift & ObjC)
@objc public enum BTAmericanExpressErrorCode: Int {
    
    case unknown = 0
    case noRewardsData = 1
    case deallocated = 2
}
