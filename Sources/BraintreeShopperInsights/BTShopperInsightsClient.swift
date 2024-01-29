import UIKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

///  Use `BTShopperInsightsClient` to optimize your checkout experience by prioritizing the customer’s preferred payment methods in your UI.
///  By customizing each customer’s checkout experience, you can improve conversion, increase sales/repeat buys and boost user retention/loyalty.
/// - Note: This feature is in beta. It's public API may change or be removed in future releases.
public class BTShopperInsightsClient {
    
    // MARK: - Internal Properties
    
    /// Defaults to `UIApplication.shared`, but exposed for unit tests to mock calls to `canOpenURL`.
    var application: URLOpener = UIApplication.shared
    
    // MARK: - Private Properties
    
    private let apiClient: BTAPIClient
    
    /// Creates a `BTShopperInsightsClient`
    /// - Parameter apiClient: A `BTAPIClient` instance.
    /// - Note: This features only works with a client token.
    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }
    
    /// This method confirms if the customer is a user of PayPal services using their email and phone number.
    /// - Parameters:
    ///   - request: A `BTShopperInsightsRequest` containing the buyer's user information
    /// - Returns: A `BTShopperInsightsResult` instance
    /// - Note: This feature is in beta. It's public API may change or be removed in future releases.
    public func getRecommendedPaymentMethods(request: BTShopperInsightsRequest) async throws -> BTShopperInsightsResult {
        apiClient.sendAnalyticsEvent(BTShopperInsightsAnalytics.recommendedPaymentsStarted)
        
        if isVenmoAppInstalled() && isPayPalAppInstalled() {
            let result = BTShopperInsightsResult(isPayPalRecommended: true, isVenmoRecommended: true)
            return notifySuccess(with: result)
        } else {
            // TODO: - Fill in appropriate merchantID (or ppClientID) from config once API team decides what we need to send
            let postParameters = BTEligiblePaymentsRequest(
                email: request.email,
                phone: request.phone,
                merchantID: "MXSJ4F5BADVNS"
            )
            
            do {
                let (json,_) = try await apiClient.post("/v2/payments/find-eligible-methods", parameters: postParameters, httpType: .payPalAPI)
                let eligibleMethodsJSON: BTJSON = json?["eligible_methods"] ?? BTJSON()
                let eligibilePaymentMethods = BTEligibilePaymentMethods(json: eligibleMethodsJSON)
                let result = BTShopperInsightsResult(
                    isPayPalRecommended: isPaymentRecommended(eligibilePaymentMethods.paypal),
                    isVenmoRecommended: isPaymentRecommended(eligibilePaymentMethods.venmo)
                )
                return self.notifySuccess(with: result)
            } catch {
                throw self.notifyFailure(with: error)
            }
        }
    }
    
    /// This method determines whether a payment source is recommended
    /// - Parameters:
    ///    - paymentMethodDetail: a `BTEligiblePaymentMethodDetails` containing the payment source's information
    /// - Returns: `true` if both `eligibleInPPNetwork` and `recommended` are enabled, otherwise returns false.
    /// - Note: This feature is in beta. It's public API may change or be removed in future releases.        -
    private func isPaymentRecommended(_ paymentMethodDetail: BTEligiblePaymentMethodDetails?) -> Bool {
        if let eligibleInPPNetwork = paymentMethodDetail?.eligibleInPaypalNetwork,
           let recommended = paymentMethodDetail?.recommended {
            return eligibleInPPNetwork && recommended
        }
        return false
    }

    /// Call this method when the PayPal button has been successfully displayed to the buyer.
    /// This method sends analytics to help improve the Shopper Insights feature experience.
    public func sendPayPalPresentedEvent() {
        apiClient.sendAnalyticsEvent(BTShopperInsightsAnalytics.paypalPresented)
    }
    
    /// Call this method when the PayPal button has been selected/tapped by the buyer.
    /// This method sends analytics to help improve the Shopper Insights feature experience
    public func sendPayPalSelectedEvent() {
        apiClient.sendAnalyticsEvent(BTShopperInsightsAnalytics.paypalSelected)
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
    
    // MARK: - Private Methods
    
    private func isVenmoAppInstalled() -> Bool {
        let venmoURL = URL(string: "com.venmo.touch.v2://")!
        return application.canOpenURL(venmoURL)
    }
    
    private func isPayPalAppInstalled() -> Bool {
        let paypalURL = URL(string: "paypal://")!
        return application.canOpenURL(paypalURL)
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
