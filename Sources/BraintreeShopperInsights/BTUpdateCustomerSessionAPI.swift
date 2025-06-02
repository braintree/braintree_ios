import UIKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The API used to update a customer session using the `UpdateCustomerSession` GraphQL mutation.
/// - Warning: This init is beta. It's public API may change or be removed in future releases. This feature only works with a client token.
final class BTUpdateCustomerSessionApi {
    
    // MARK: - Properties
    
    /// Exposed for testing to get the instance of `BTAPIClient`
    private var apiClient: BTAPIClient
    
    // MARK: - Initializer
    
    /// Creates a `BTUpdateCustomerSessionApi`
    /// - Parameters:
    ///    - apiClient: A `BTAPIClient` instance
    init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }
    
    /// This method will call the `UpdateCustomerSession` GQL mutation, which returns a sessionId if successful.
    /// - Parameters:
    ///    - request: A `BTCustomerSessionRequest`
    ///    - completion: This completion will be invoked when the attempt to create a customer session is complete or an error occurs. On success, you will receive a sessionId; on failure you will receive an error.
    func execute(
        _ request: BTCustomerSessionRequest,
        sessionId: String
    ) async throws -> String {
        do {
            let graphQLParams = try UpdateCustomerSessionMutationGraphQLBody(request: request)
            
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
