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

    /// With the new init, we wouldn’t need to expose this property — it should be injected as a dependency instead.
    /// Exposed for testing to get the instance of BTAPIClient
    var apiClient: BTAPIClient

    private let authorization: String
    private let shopperSessionID: String?
    private let findEligibleMethodService: BTFindEligibleMethodsServiceable

    /// Creates a `BTShopperInsightsClient`
    ///
    /// - Parameters:
    ///     - authorization: A valid client token or tokenization key used to authorize API calls
    ///     - shopperSessionID: Optional: This value should be the shopper session ID returned from your server SDK request
    /// - Warning: This init is beta. It's public API may change or be removed in future releases. This feature only works with a client token.
    public convenience init(authorization: String, shopperSessionID: String? = nil) {
        let apiClient = BTAPIClient(authorization: authorization)
        let service = BTFindEligibleMethodsService(apiClient: apiClient)
        self.init(
            authorization: authorization,
            shopperSessionID: shopperSessionID,
            apiClient: apiClient,
            findEligibleMethodService: service
        )
    }
    
    // Internal init for testability (inject BTFindEligibleMethodsServiceable mock)
    init(
        authorization: String,
        shopperSessionID: String?,
        apiClient: BTAPIClient,
        findEligibleMethodService: BTFindEligibleMethodsServiceable
    ) {
        self.apiClient = apiClient
        self.authorization = authorization
        self.shopperSessionID = shopperSessionID
        self.findEligibleMethodService = findEligibleMethodService
    }
    
    // MARK: - Public Methods

    /// This method confirms if the customer is a user of PayPal services using their email and phone number.
    /// - Parameters:
    ///   - request: Required:  A `BTShopperInsightsRequest` containing the buyer's user information.
    ///   - experiment: Optional:  A `JSONObject` passed in as a string containing details of the merchant experiment.
    /// - Returns: A `BTShopperInsightsResult` instance
    /// - Warning: This feature is in beta. Its public API may change or be removed in future releases.
    ///         PayPal recommendation is only available for US, AU, FR, DE, ITA, NED, ESP, Switzerland and UK merchants.
    ///         Venmo recommendation is only available for US merchants.
    public func getRecommendedPaymentMethods(
        request: BTShopperInsightsRequest,
        experiment: String? = nil
    ) async throws -> BTShopperInsightsResult {
        apiClient.sendAnalyticsEvent(
            BTShopperInsightsAnalytics.recommendedPaymentsStarted,
            merchantExperiment: experiment,
            shopperSessionID: shopperSessionID
        )

        if apiClient.authorization.type != .clientToken {
            throw notifyFailure(with: BTShopperInsightsError.invalidAuthorization, for: experiment)
        }

        do {
            let response = try await findEligibleMethodService.execute(request)
            return notifySuccess(with: response, for: experiment)
        } catch {
            throw notifyFailure(with: error, for: experiment)
        }
    }

    /// Call this method when the PayPal or Venmo button has been successfully displayed to the buyer.
    /// This method sends analytics to help improve the Shopper Insights feature experience.
    /// - Parameters:
    ///    - buttonType: Type of button presented - PayPal, Venmo, or Other
    ///    - presentmentDetails: Detailed information, including button order, experiment type, and
    ///     page type about the payment button that is sent to analytics to help improve the Shopper Insights
    ///     feature experience.
    public func sendPresentedEvent(for buttonType: BTButtonType, presentmentDetails: BTPresentmentDetails) {
        apiClient.sendAnalyticsEvent(
            BTShopperInsightsAnalytics.buttonPresented,
            buttonOrder: presentmentDetails.buttonOrder.rawValue,
            buttonType: buttonType.rawValue,
            merchantExperiment: presentmentDetails.experimentType.formattedExperiment,
            pageType: presentmentDetails.pageType.rawValue,
            shopperSessionID: shopperSessionID
        )
    }

    /// Call this method when a button has been selected/tapped by the buyer.
    /// This method sends analytics to help improve the Shopper Insights feature experience.
    /// - Parameter buttonType: Type of button presented - PayPal, Venmo, or Other
    /// - Warning: This function is in beta. It's public API may change or be removed in future releases.
    public func sendSelectedEvent(for buttonType: BTButtonType) {
        apiClient.sendAnalyticsEvent(
            BTShopperInsightsAnalytics.buttonSelected,
            buttonType: buttonType.rawValue,
            shopperSessionID: shopperSessionID
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

    // MARK: - Analytics Helper Methods
    
    private func notifySuccess(with result: BTShopperInsightsResult, for experiment: String?) -> BTShopperInsightsResult {
        apiClient.sendAnalyticsEvent(
            BTShopperInsightsAnalytics.recommendedPaymentsSucceeded,
            merchantExperiment: experiment,
            shopperSessionID: shopperSessionID
        )
        return result
    }
    
    private func notifyFailure(with error: Error, for experiment: String?) -> Error {
        apiClient.sendAnalyticsEvent(
            BTShopperInsightsAnalytics.recommendedPaymentsFailed,
            errorDescription: error.localizedDescription,
            merchantExperiment: experiment,
            shopperSessionID: shopperSessionID
        )
        return error
    }
}
