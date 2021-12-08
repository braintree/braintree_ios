import Foundation

///  Error codes associated with American Express.
@objcMembers public class BTAmericanExpressError: Error, LocalizedError {

//    /// Unknown error
//    case unknown
//
//    /// An API response was received with missing rewards data
//    case noRewardsData
//

    static var errorDomain: String {
        "com.braintreepayments.BTAmericanExpressErrorDomain"
    }

    // TODO: Revist scope of the error code
   enum ErrorCode: Int {
        case unknown
        case noRewardsData
    }
    
    public static let unknownError = NSError(
        domain: errorDomain,
        code: ErrorCode.unknown.rawValue,
        userInfo: [errorDomain: "An unknown error occured. Please contact support."]
    )
    
    public static let noRewardsDataError = NSError(
        domain: errorDomain,
        code: ErrorCode.noRewardsData.rawValue,
        userInfo: [errorDomain: "No American Express Rewards data was returned. Please contact support."]
    )

//
//    var errorDescription: String? {
//        switch self {
//        case .unknown:
//            return "An unknown error occured. Please contact support."
//
//        case .noRewardsData:
//            return "No American Express Rewards data was returned. Please contact support."
//        }
//    }

}
