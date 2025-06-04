import UIKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The API used to update a customer session using the `UpdateCustomerSession` GraphQL mutation.
final class BTUpdateCustomerSessionApi {
    
    // MARK: - Properties
    
    private var apiClient: BTAPIClient
    
    // MARK: - Initializer
    
    /// Creates a `BTUpdateCustomerSessionApi`
    /// - Parameters:
    ///    - apiClient: A `BTAPIClient` instance
    init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }
    
    /// This method will call the `UpdateCustomerSession` GQL mutation, which returns a session ID if successful.
    /// - Parameters:
    ///    - request: A `BTCustomerSessionRequest`
    ///    - sessionID: The session ID to update.
    ///    - Returns: A `String` containing the customer session ID if successful.
    ///    - Throws: An error if the request fails or if the response is invalid.
    func execute(
        _ request: BTCustomerSessionRequest,
        sessionID: String
    ) async throws -> String {
        do {
            let graphQLParams = try UpdateCustomerSessionMutationGraphQLBody(request: request, sessionID: sessionID)
            
            let (body, _) = try await apiClient.post("", parameters: graphQLParams, httpType: .graphQLAPI)
            
            guard let body else {
                throw BTHTTPError.dataNotFound
            }
            
            guard let customerSessionID = body["data"]["updateCustomerSession"]["sessionId"].asString() else {
                throw BTHTTPError.httpResponseInvalid
            }
            
            return customerSessionID
        } catch {
            throw error
        }
    }
}
