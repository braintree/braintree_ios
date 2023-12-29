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
        if isVenmoAppInstalled() && isPayPalAppInstalled() {
            return BTShopperInsightsResult(isPayPalRecommended: true, isVenmoRecommended: true)
        }
        
        // TODO: - Make API call to PaymentReadyAPI. DTBTSDK-3176
        return BTShopperInsightsResult()
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
}
