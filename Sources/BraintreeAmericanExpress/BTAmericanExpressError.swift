import Foundation

///  Error details associated with American Express.
public enum BTAmericanExpressError: Int, Error, CustomNSError, LocalizedError, Equatable {

    /// 0. Unknown error
    case unknown

    /// 1. An API response was received with missing rewards data
    case noRewardsData

    /// 2. Deallocated BTAmericanExpressClient
    case deallocated

    public static var errorDomain: String {
        "com.braintreepayments.BTAmericanExpressErrorDomain"
    }
    
    public var errorCode: Int {
        rawValue
    }

    public var errorDescription: String? {
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
