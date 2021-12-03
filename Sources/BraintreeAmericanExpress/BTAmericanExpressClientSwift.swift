import Foundation


///  Domain for American Express errors.
// TODO: Make this accessible in objc
public let BTAmericanExpressErrorDomainSwift: String = "com.braintreepayments.BTAmericanExpressErrorDomain"

// TODO: Does this class need to inherit from NSObject?

@objcMembers public class BTAmericanExpressClientSwift: NSObject {
    
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
    ///  @note If the nonce is associated with an ineligible card or a card with insufficient points, the rewardsBalance will contain this information as `errorMessage` and `errorCode`.
    public func getRewardsBalance(forNonce nonce: String, currencyIsoCode: String, completion: @escaping (BTAmericanExpressRewardsBalance?, Error?) -> Void) {
        var parameters = ["currencyIsoCode": currencyIsoCode,
                          "paymentMethodNonce": nonce]
        // TODO: Investigate how to expose analytics
        // [self.apiClient sendAnalyticsEvent:@"ios.amex.rewards-balance.start"];
        
        self.apiClient.get("v1/payment_methods/amex_rewards_balance", parameters: parameters) { body, response, error in
            if let error = error {
                // [self.apiClient sendAnalyticsEvent:@"ios.amex.rewards-balance.error"];
                completion(nil, error)
                return
            }
            if let body = body {
                let rewardsBalance = BTAmericanExpressRewardsBalance(json: body)
                // [self.apiClient sendAnalyticsEvent:@"ios.amex.rewards-balance.success"];
                completion(rewardsBalance, nil)
            } else {
                // TODO: We are returning an empty rewards balance here because this is exactly what happens in obj-C, but in Swift we should explicitly handle this error case
                completion(BTAmericanExpressRewardsBalance(json: BTJSON()), nil)
            }
        }
        
    }
}
