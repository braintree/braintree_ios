import UIKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The API used to update a customer session using the `UpdateCustomerSession` GraphQL mutation.
final class BTUpdateCustomerSessionAPI {
    
    // MARK: - Properties
    
    private let apiClient: BTAPIClient
    
    // MARK: - Initializer
    
    /// Creates a `BTUpdateCustomerSessionAPI`
    /// - Parameters:
    ///    - apiClient: A `BTAPIClient` instance
    init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }
    
    /// This method will call the `UpdateCustomerSession` GQL mutation, which returns a session ID if successful.
    /// - Parameters:
    ///    - request: A `BTCustomerSessionRequest`
    ///    - sessionID: The session ID to update.
    ///    - Returns: A `String` containing the session ID
    ///    - Throws: An error if the request fails or if the response is invalid.
    func execute(
        _ request: BTCustomerSessionRequest,
        sessionID: String
    ) async throws -> String {
        do {
            apiClient.sendAnalyticsEvent(BTShopperInsightsAnalytics.updateCustomerSessionStarted)
            
            let graphQLParams = UpdateCustomerSessionMutationGraphQLBody(request: request, sessionID: sessionID)
            
            let (body, _) = try await apiClient.post("", parameters: graphQLParams, httpType: .graphQLAPI)
            
            guard let body else {
                throw BTShopperInsightsError.emptyBodyReturned
            }
            
            guard let sessionID = body["data"]["updateCustomerSession"]["sessionId"].asString() else {
                throw BTHTTPError.httpResponseInvalid
            }
            
            apiClient.sendAnalyticsEvent(BTShopperInsightsAnalytics.updateCustomerSessionSucceeded)
            return sessionID
        } catch {
            apiClient.sendAnalyticsEvent(BTShopperInsightsAnalytics.updateCustomerSessionFailed)
            throw error
        }
    }
}
