import UIKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

///  Use `BTShopperInsightsClientV2` to optimize your checkout experience by prioritizing the customer’s preferred payment methods in your UI.
///
///  By customizing each customer’s checkout experience, you can improve conversion, increase sales/repeat buys and boost user retention/loyalty.
///
///  The use of this client is a completely separate integration path from the deprecated `BTShopperInsightsClient`
/// - Warning: This feature is in beta. It's public API may change or be removed in future releases.
public class BTShopperInsightsClientV2 {
    
    // MARK: - Internal Properties
    
    /// Defaults to `UIApplication.shared`, but exposed for unit tests to mock calls to `canOpenURL`.
    var application: URLOpener = UIApplication.shared
    
    // MARK: - Private Properties
    
    private let apiClient: BTAPIClient
    
    // MARK: - Initializers
    
    /// Creates a `BTShopperInsightsClientV2`
    /// - Parameters:
    ///    - apiClient: A `BTAPIClient` instance.
    /// - Warning: This init is beta. It's public API may change or be removed in future releases. This feature only works with a client token.
    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }
    
    // MARK: - Public Methods
    
    /// Call this method when the PayPal or Venmo button has been successfully displayed to the buyer.
    /// This method sends analytics to help improve the Shopper Insights feature experience.
    /// - Parameters:
    ///    - buttonType: Type of button presented - PayPal, Venmo, or Other
    ///    - presentmentDetails: Detailed information, including button order, experiment type, and
    ///     page type about the payment button that is sent to analytics to help improve the Shopper Insights
    ///     feature experience.
    ///    - sessionID: The shopper session ID
    /// - Warning: This function is in beta. It's public API may change or be removed in future releases.
    public func sendPresentedEvent(for buttonType: BTButtonType, presentmentDetails: BTPresentmentDetails, sessionID: String) {
        apiClient.sendAnalyticsEvent(
            BTShopperInsightsAnalytics.buttonPresented,
            buttonOrder: presentmentDetails.buttonOrder.rawValue,
            buttonType: buttonType.rawValue,
            merchantExperiment: presentmentDetails.experimentType.formattedExperiment,
            pageType: presentmentDetails.pageType.rawValue,
            shopperSessionID: sessionID
        )
    }

    /// Call this method when a button has been selected/tapped by the buyer.
    /// This method sends analytics to help improve the Shopper Insights feature experience.
    /// - Parameters:
    ///    - buttonType: Type of button presented - PayPal, Venmo, or Other
    ///    - sessionID: The shopper session ID
    /// - Warning: This function is in beta. It's public API may change or be removed in future releases.
    public func sendSelectedEvent(for buttonType: BTButtonType, sessionID: String) {
        apiClient.sendAnalyticsEvent(
            BTShopperInsightsAnalytics.buttonSelected,
            buttonType: buttonType.rawValue,
            shopperSessionID: sessionID
        )
    }
    
    /// Indicates whether the PayPal App is installed.
    /// - Warning: This method is currently in beta and may change or be removed in future releases.
    public func isPayPalAppInstalled() -> Bool {
        application.isPayPalAppInstalled()
    }

    /// Indicates whether the Venmo App is installed.
    /// - Warning: This method is currently in beta and may change or be removed in future releases.
    public func isVenmoAppInstalled() -> Bool {
        application.isVenmoAppInstalled()
    }
}
