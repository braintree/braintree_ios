import UIKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

///  Use `BTShopperInsightsClient` to optimize your checkout experience by prioritizing the customer’s preferred payment methods in your UI.
///  By customizing each customer’s checkout experience, you can improve conversion, increase sales/repeat buys and boost user retention/loyalty.
/// - Warning: This feature is in beta. It's public API may change or be removed in future releases.
public class BTShopperInsightsClient {
    
    // MARK: - Internal Properties
    
    /// Defaults to `UIApplication.shared`, but exposed for unit tests to mock calls to `canOpenURL`.
    var application: URLOpener = UIApplication.shared
    
    // MARK: - Private Properties
    
    private let apiClient: BTAPIClient
    
    /// Creates a `BTShopperInsightsClient`
    /// - Parameter apiClient: A `BTAPIClient` instance.
    /// - Warning: This features only works with a client token.
    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }
    
    /// This method confirms if the customer is a user of PayPal services using their email and phone number.
    /// - Parameters:
    ///   - request: A `BTShopperInsightsRequest` containing the buyer's user information
    /// - Returns: A `BTShopperInsightsResult` instance
    /// - Warning: This feature is in beta. Its public API may change or be removed in future releases.
    ///         PayPal recommendation is only available for US, AU, FR, DE, ITA, NED, ESP, Switzerland and UK merchants.
    ///         Venmo recommendation is only available for US merchants.
    public func getRecommendedPaymentMethods(request: BTShopperInsightsRequest) async throws -> BTShopperInsightsResult {
        apiClient.sendAnalyticsEvent(BTShopperInsightsAnalytics.recommendedPaymentsStarted)
        
        let postParameters = BTEligiblePaymentsRequest(
            email: request.email,
            phone: request.phone
        )
        
        do {
            let (json, _) = try await apiClient.post(
                "/v2/payments/find-eligible-methods",
                parameters: postParameters,
                headers: ["PayPal-Client-Metadata-Id": apiClient.metadata.sessionID],
                httpType: .payPalAPI
            )

            guard let eligibleMethodsJSON = json?["eligible_methods"].asDictionary(),
                  eligibleMethodsJSON.count != 0 else {
                throw self.notifyFailure(with: BTShopperInsightsError.emptyBodyReturned)
            }
            
            let eligiblePaymentMethods = BTEligiblePaymentMethods(json: json)
            let result = BTShopperInsightsResult(
                isPayPalRecommended: eligiblePaymentMethods.payPal?.recommended ?? false,
                isVenmoRecommended: eligiblePaymentMethods.venmo?.recommended ?? false,
                isEligibleInPayPalNetwork: eligiblePaymentMethods.payPal?.eligibleInPayPalNetwork ?? false || eligiblePaymentMethods.venmo?.eligibleInPayPalNetwork ?? false
            )
            return self.notifySuccess(with: result)
        } catch {
            throw self.notifyFailure(with: error)
        }
    }

    /// Call this method when the PayPal button has been successfully displayed to the buyer.
    /// This method sends analytics to help improve the Shopper Insights feature experience.
    public func sendPayPalPresentedEvent() {
        apiClient.sendAnalyticsEvent(BTShopperInsightsAnalytics.payPalPresented)
    }
    
    /// Call this method when the PayPal button has been selected/tapped by the buyer.
    /// This method sends analytics to help improve the Shopper Insights feature experience
    public func sendPayPalSelectedEvent() {
        apiClient.sendAnalyticsEvent(BTShopperInsightsAnalytics.payPalSelected)
    }
    
    /// Call this method when the Venmo button has been successfully displayed to the buyer.
    /// This method sends analytics to help improve the Shopper Insights feature experience
    public func sendVenmoPresentedEvent() {
        apiClient.sendAnalyticsEvent(BTShopperInsightsAnalytics.venmoPresented)
    }
    
    /// Call this method when the Venmo button has been selected/tapped by the buyer.
    /// This method sends analytics to help improve the Shopper Insights feature experience
    public func sendVenmoSelectedEvent() {
        apiClient.sendAnalyticsEvent(BTShopperInsightsAnalytics.venmoSelected)
    }
    
    // MARK: - Analytics Helper Methods
    
    private func notifySuccess(with result: BTShopperInsightsResult) -> BTShopperInsightsResult {
        apiClient.sendAnalyticsEvent(BTShopperInsightsAnalytics.recommendedPaymentsSucceeded)
        return result
    }
    
    private func notifyFailure(with error: Error) -> Error {
        apiClient.sendAnalyticsEvent(BTShopperInsightsAnalytics.recommendedPaymentsFailed, errorDescription: error.localizedDescription)
        return error
    }
}
