import Foundation


@objc public class BTAmericanExpressError: NSObject {
    
    ///  Domain for American Express errors.
    @objc public static let Domain = "com.braintreepayments.BTAmericanExpressErrorDomain"
    
    /**
     Error codes associated with American Express.
     */
    @objc public enum Code: Int {
        /// Unknown error
        case unknown
        
        /// Empty response
        case emptyResponse
    }
}
