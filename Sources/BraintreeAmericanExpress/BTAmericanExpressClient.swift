import Foundation
import BraintreeCore


// TODO: Convert this enum to Swift
///**
// Error codes associated with American Express.
// */
//typedef NS_ENUM(NSInteger, BTAmericanExpressErrorType) {
//    /// Unknown error
//    BTAmericanExpressErrorTypeUnknown = 0,
//};

///  `BTAmericanExpressClient` enables you to look up the rewards balance of American Express cards.
@objcMembers public class BTAmericanExpressClient: NSObject {
    
    ///  Domain for American Express errors.
    @objc public static let BTAmericanExpressErrorDomain = "com.braintreepayments.BTAmericanExpressErrorDomain"
    
        ///  Exposed for testing to get the instance of BTAPIClient
    private var apiClient: BTAPIClient
    
    ///  Creates an American Express client.
    /// - Parameter apiClient: An API client
    @objc(initWithAPIClient:)
    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }
    
    ///  Gets the rewards balance associated with a Braintree nonce. Only for American Express cards.
    /// - Parameters:
    ///   - nonce: A nonce representing a card that will be used to look up the rewards balance.
    ///   - currencyIsoCode:  The currencyIsoCode to use. Example: 'USD'
    ///   - completion:  A completion block that is invoked when the request has completed. If the request succeeds,
    ///   `rewardsBalance` will contain information about the rewards balance and `error` will be `nil` (see exceptions in note);
    ///   if it fails, `rewardsBalance` will be `nil` and `error` will describe the failure.
    ///  - Note: If the nonce is associated with an ineligible card or a card with insufficient points, the rewardsBalance will contain this information as `errorMessage` and `errorCode`.
    public func getRewardsBalance(forNonce nonce: String, currencyIsoCode: String, completion: @escaping (BTAmericanExpressRewardsBalance?, Error?) -> Void) {
    
        let parameters = ["currencyIsoCode": currencyIsoCode,
                          "paymentMethodNonce": nonce]
        // TODO: Investigate how to expose analytics
        // [self.apiClient sendAnalyticsEvent:@"ios.amex.rewards-balance.start"];

        self.apiClient.get("v1/payment_methods/amex_rewards_balance", parameters: parameters) { body, response, error in
            if let error = error {
                // [self.apiClient sendAnalyticsEvent:@"ios.amex.rewards-balance.error"];
                completion(nil, error)
                return
            }
            
            guard let body = body else {
                // [self.apiClient sendAnalyticsEvent:@"ios.amex.rewards-balance.error"];
                completion(nil, BTAmericanExpressError.emptyResponse)
                return
            }
            
            let rewardsBalance = BTAmericanExpressRewardsBalance(json: body)
            // [self.apiClient sendAnalyticsEvent:@"ios.amex.rewards-balance.success"];
            completion(rewardsBalance, nil)
        }
    }
}
