import UIKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The API used to create a customer session using the `CreateCustomerSession` GraphQL mutation.
final class BTCreateCustomerSessionAPI {
    
    // MARK: - Properties
    
    private var apiClient: BTAPIClient
    
    // MARK: - Initializer
    
    /// Creates a `BTCreateCustomerSessionAPI`
    /// - Parameters:
    ///    - apiClient: A `BTAPIClient` instance
    init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }
    
    /// This method will call the `CreateCustomerSession` GQL mutation, which returns a session ID if successful.
    /// - Parameters:
    ///    - request: A `BTCustomerSessionRequest`
    ///    - completion: This completion will be invoked when the attempt to create a customer session is complete or an error occurs. On success, you will receive a session ID; on failure you will receive an error.
    func execute(
        _ request: BTCustomerSessionRequest,
        completion: @escaping (String?, Error?) -> Void
    ) {
        do {
            let graphQLParams = try CreateCustomerSessionMutationGraphQLBody(request: request)
            
            self.apiClient.post("", parameters: graphQLParams, httpType: .graphQLAPI) { body, _, error in
                if let error {
                    completion(nil, error)
                    return
                }
                
                guard let body else {
                    completion(nil, BTShopperInsightsError.emptyBodyReturned)
                    return
                }
                
                guard let sessionID = body["data"]["createCustomerSession"]["sessionId"].asString() else {
                    completion(nil, BTHTTPError.httpResponseInvalid)
                    return
                }
                completion(sessionID, nil)
            }
        } catch {
            completion(nil, error)
        }
    }
}
