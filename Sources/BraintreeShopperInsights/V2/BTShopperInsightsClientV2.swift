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
    
    /// Exposed for testing to get the instance of BTAPIClient
    var apiClient: BTAPIClient
    
    // MARK: - Initializers
    
    /// Creates a `BTShopperInsightsClientV2`
    /// - Parameters:
    ///    - authorization: A valid client token or tokenization key used to authorize API calls.
    /// - Warning: This init is beta. It's public API may change or be removed in future releases. This feature only works with a client token.
    public init(authorization: String) {
        self.apiClient = BTAPIClient(authorization: authorization)
    }
    
    // MARK: - Public Methods
    
    /// This method creates a new customer session.
    /// - Parameters:
    ///    - request: A `BTCustomerSessionRequest`
    /// - Returns: A `String` representing a session ID if successful
    /// - Throws: An error if the request fails for some reason or if the response is invalid.
    /// - Warning: This method is currently in beta and may change or be removed in future releases.
    public func createCustomerSession(request: BTCustomerSessionRequest) async throws -> String {
        let createCustomerSessionAPI = BTCreateCustomerSessionAPI(apiClient: apiClient)
        return try await createCustomerSessionAPI.execute(request)
    }
    
    /// This method updates an existing customer session.
    /// - Parameters:
    ///    - request: A `BTCustomerSessionRequest`
    ///    - sessionID: the ID of the session to update
    /// - Returns: A `String` representing a session ID if successful
    /// - Throws: An error if the request fails for some reason or if the response is invalid.
    /// - Warning: This method is currently in beta and may change or be removed in future releases.
    public func updateCustomerSession(request: BTCustomerSessionRequest, sessionID: String) async throws -> String {
        let updateCustomerSessionAPI = BTUpdateCustomerSessionAPI(apiClient: apiClient)
        return try await updateCustomerSessionAPI.execute(request, sessionID: sessionID)
    }
    
    /// Generates customer recommendations
    /// - Parameters:
    ///    - request: Optional. request type `BTCustomerSessionRequest`
    ///    - sessionID: Optional. The shopper session ID
    /// - Warning: This method is currently in beta and may change or be removed in future releases.
    public func generateCustomerRecommendations(
        request: BTCustomerSessionRequest?,
        sessionID: String?
    ) async throws -> BTCustomerRecommendationsResult {
        let customerRecommendationsAPI = BTCustomerRecommendationsAPI(apiClient: apiClient)
        return try await customerRecommendationsAPI.execute(request, sessionID: sessionID)
    }
    
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
