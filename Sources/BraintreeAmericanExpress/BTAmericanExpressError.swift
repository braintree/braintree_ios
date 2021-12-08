import Foundation

///  Error details associated with American Express.
enum BTAmericanExpressError: Error, CustomNSError, LocalizedError {

    /// Unknown error
    case unknown

    /// An API response was received with missing rewards data
    case noRewardsData

    static var errorDomain: String {
        "com.braintreepayments.BTAmericanExpressErrorDomain"
    }
    
    var errorCode: Int {
        switch self {
        case .unknown:
            return 0
        case .noRewardsData:
            return 1
        }
    }

    var errorDescription: String? {
        switch self {
        case .unknown:
            return "An unknown error occured. Please contact support."

        case .noRewardsData:
            return "No American Express Rewards data was returned. Please contact support."
        }
    }
}
