import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

///  `BTAmericanExpressClient` enables you to look up the rewards balance of American Express cards.
@objc public class BTAmericanExpressClient: NSObject {
    
    /// exposed for testing
    var apiClient: BTAPIClient
    
    ///  Creates an American Express client.
    /// - Parameter authorization: A valid client token or tokenization key used to authorize API calls
    @objc(initWithAuthorization:)
    public init(authorization: String) {
        self.apiClient = BTAPIClient(authorization: authorization)
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
    public func getRewardsBalance(
        forNonce nonce: String,
        currencyISOCode: String,
        completion: @escaping (BTAmericanExpressRewardsBalance?, Error?) -> Void
    ) {
        Task {
            do {
                let rewardsBalance = try await getRewardsBalance(forNonce: nonce, currencyISOCode: currencyISOCode)
                completion(rewardsBalance, nil)
            } catch {
                completion(nil, error)
            }
        }
    }

    ///  Gets the rewards balance associated with a Braintree nonce. Only for American Express cards.
    /// - Parameters:
    ///   - nonce: A nonce representing a card that will be used to look up the rewards balance.
    ///   - currencyISOCode: The currencyIsoCode to use. Example: 'USD'
    /// - Returns: A `BTAmericanExpressRewardsBalance` object with information about the rewards balance
    /// - Throws: An `Error` describing the failure
    public func getRewardsBalance(forNonce nonce: String, currencyISOCode: String) async throws -> BTAmericanExpressRewardsBalance {
        let parameters = BTAmexRewardsBalanceRequest(currencyIsoCode: currencyISOCode, paymentMethodNonce: nonce)
        apiClient.sendAnalyticsEvent(BTAmericanExpressAnalytics.started)

        do {
            let (body, _) = try await apiClient.get("v1/payment_methods/amex_rewards_balance", parameters: parameters)

            guard let body else {
                throw BTAmericanExpressError.noRewardsData
            }

            let rewardsBalance = BTAmericanExpressRewardsBalance(json: body)
            return notifySuccess(with: rewardsBalance)
        } catch {
            sendFailureAnalytics(with: error)
            throw error
        }
    }

    // MARK: - Analytics Helper Methods

    private func notifySuccess(with result: BTAmericanExpressRewardsBalance) -> BTAmericanExpressRewardsBalance {
        apiClient.sendAnalyticsEvent(BTAmericanExpressAnalytics.succeeded)
        return result
    }

    private func sendFailureAnalytics(with error: Error) {
        apiClient.sendAnalyticsEvent(
            BTAmericanExpressAnalytics.failed,
            errorDescription: error.localizedDescription
        )
    }
}
