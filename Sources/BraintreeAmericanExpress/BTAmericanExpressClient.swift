import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

///  `BTAmericanExpressClient` enables you to look up the rewards balance of American Express cards.
@objc public class BTAmericanExpressClient: NSObject {
    
    private let apiClient: BTAPIClient
    
    ///  Creates an American Express client.
    /// - Parameter apiClient: An instance of `BTAPIClient`
    @objc(initWithAPIClient:)
    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }
    
    ///  Gets the rewards balance associated with a Braintree nonce. Only for American Express cards.
    /// - Parameters:
    ///   - nonce: A nonce representing a card that will be used to look up the rewards balance.
    ///   - currencyISOCode:  The currencyIsoCode to use. Example: 'USD'
    ///   - completion:  A completion block that is invoked when the request has completed. If the request succeeds,
    ///   `rewardsBalance` will contain information about the rewards balance and `error` will be `nil` (see exceptions in note);
    ///   if it fails, `rewardsBalance` will be `nil` and `error` will describe the failure.
    ///  - Note: If the nonce is associated with an ineligible card or a card with insufficient points, the rewardsBalance will contain this information as `errorMessage` and `errorCode`.
    @objc(getRewardsBalanceForNonce:currencyIsoCode:completion:)
    public func getRewardsBalance(forNonce nonce: String, currencyISOCode: String, completion: @escaping (BTAmericanExpressRewardsBalance?, Error?) -> Void) {
        let parameters = ["currencyIsoCode": currencyISOCode, "paymentMethodNonce": nonce]
        apiClient.sendAnalyticsEvent(BTAmericanExpressAnalytics.rewardsBalanceStarted)

        apiClient.get("v1/payment_methods/amex_rewards_balance", parameters: parameters) { [weak self] body, response, error in
            guard let self else {
                completion(nil, BTAmericanExpressError.deallocatedBTAmericanExpressClient)
                return
            }

            if let error = error {
                self.apiClient.sendAnalyticsEvent(BTAmericanExpressAnalytics.rewardsBalanceFailed)
                completion(nil, error)
                return
            }

            guard let body = body else {
                self.apiClient.sendAnalyticsEvent(BTAmericanExpressAnalytics.rewardsBalanceFailed)
                completion(nil, BTAmericanExpressError.noRewardsData)
                return
            }

            let rewardsBalance = BTAmericanExpressRewardsBalance(json: body)
            self.apiClient.sendAnalyticsEvent(BTAmericanExpressAnalytics.rewardsBalanceSucceeded)
            completion(rewardsBalance, nil)
            return
        }
    }

    ///  Gets the rewards balance associated with a Braintree nonce. Only for American Express cards.
    /// - Parameters:
    ///   - nonce: A nonce representing a card that will be used to look up the rewards balance.
    ///   - currencyISOCode: The currencyIsoCode to use. Example: 'USD'
    /// - Returns: A `BTAmericanExpressRewardsBalance` object with information about the rewards balance
    /// - Throws: An `Error` describing the failure
    public func getRewardsBalance(forNonce nonce: String, currencyISOCode: String) async throws -> BTAmericanExpressRewardsBalance {
        try await withCheckedThrowingContinuation { continuation in
            getRewardsBalance(forNonce: nonce, currencyISOCode: currencyISOCode) { rewardsBalance, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let rewardsBalance {
                    continuation.resume(returning: rewardsBalance)
                }
            }
        }
    }
}
