import UIKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The API used to create a customer session using the `CreateCustomerSession` GraphQL mutation.
final class BTCreateCustomerSessionAPI {
    
    // MARK: - Private Properties
    
    private let apiClient: BTAPIClient
    
    // MARK: - Initializer
    
    /// Creates a `BTCreateCustomerSessionAPI`
    /// - Parameters:
    ///    - apiClient: A `BTAPIClient` instance
    init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }
    
    // MARK: - Internal Methods
    
    /// This method will call the `CreateCustomerSession` GQL mutation, which returns a session ID if successful.
    /// - Parameters:
    ///    - request: A `BTCustomerSessionRequest`
    ///    - Returns: A `String` representing the session ID
    ///    - Throws: An error if the request fails or if the response is invalid.
    func execute(_ request: BTCustomerSessionRequest) async throws -> String {
        do {
            apiClient.sendAnalyticsEvent(BTShopperInsightsAnalytics.createCustomerSessionStarted)
            
            let graphQLParams = CreateCustomerSessionMutationGraphQLBody(request: request)
            
            let (body, _) = try await apiClient.post("", parameters: graphQLParams, httpType: .graphQLAPI)

            guard let body else {
                throw BTShopperInsightsError.emptyBodyReturned
            }
            
            guard let sessionID = body["data"]["createCustomerSession"]["sessionId"].asString() else {
                throw BTHTTPError.httpResponseInvalid
            }
           
            apiClient.sendAnalyticsEvent(
                BTShopperInsightsAnalytics.createCustomerSessionSucceeded,
                shopperSessionID: sessionID
            )
            return sessionID
        } catch {
            apiClient.sendAnalyticsEvent(
                BTShopperInsightsAnalytics.createCustomerSessionFailed,
                errorDescription: error.localizedDescription
            )
            throw error
        }
    }
}
