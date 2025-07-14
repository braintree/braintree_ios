import UIKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

final class BTCustomerRecommendationsAPI {
    
    // MARK: - Properties
    
    private let apiClient: BTAPIClient
    
    // MARK: - Initializer
    
    /// Creates a `BTCustomerRecommendationsAPI`
    /// - Parameters:
    ///    - apiClient: A `BTAPIClient` instance
    init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }
    
    /// This method will call the `GenerateCustomerRecommendations` GQL query, which returns a `BTCustomerRecommendationsResult` if successful.
    /// - Parameters:
    ///    - request: A `BTCustomerSessionRequest`
    ///    - sessionID: The session ID to update.
    ///    - Returns: A `BTCustomerRecommendationsResult` which determines what payment options to render.
    ///    - Throws: An error if the request fails or if the response is invalid.
    func execute(
        _ request: BTCustomerSessionRequest,
        sessionID: String
    ) async throws -> BTCustomerRecommendationsResult {
        do {
            apiClient.sendAnalyticsEvent(BTShopperInsightsAnalytics.generateCustomerRecommendationsStarted)
            let graphQLParameters = GenerateCustomerRecommendationsGraphQLBody(request: request, sessionID: sessionID)
            let (body, _) = try await apiClient.post("", parameters: graphQLParameters, httpType: .graphQLAPI)
            
            guard let body else {
                throw BTShopperInsightsError.emptyBodyReturned
            }
            
            let sessionID = body["data"]["generateCustomerRecommendations"]["sessionId"].asString()
            let isInPayPalNetwork = body["data"]["generateCustomerRecommendations"]["isInPayPalNetwork"].asBool()
            var paymentOptions: [BTPaymentOptions]? = []
            if let paymentRecommendations = body["data"]["generateCustomerRecommendations"]["paymentRecommendations"].asArray() {
                for recommendation in paymentRecommendations {
                    paymentOptions?.append(
                        BTPaymentOptions(
                            paymentOption: recommendation["paymentOption"].asString() ?? "",
                            recommendedPriority: recommendation["recommendedPriority"].asIntegerOrZero()
                        )
                    )
                }
            }
            
            apiClient.sendAnalyticsEvent(
                BTShopperInsightsAnalytics.generateCustomerRecommendationsSucceeded,
                shopperSessionID: sessionID
            )
            return BTCustomerRecommendationsResult(
                sessionID: sessionID,
                isInPayPalNetwork: isInPayPalNetwork,
                paymentRecommendations: paymentOptions
            )
        } catch let error as NSError {
            apiClient.sendAnalyticsEvent(
                BTShopperInsightsAnalytics.generateCustomerRecommendationsFailed,
                errorDescription: error.localizedDescription
            )
            throw error
        }
    }
}
