import UIKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The API used to create a customer session using the `CreateCustomerSession` GraphQL mutation.
/// - Warning: This feature is in beta. It's public API may change or be removed in future releases.
class BTCreateCustomerSessionAPI {
    
    // MARK: - Properties
    
    /// Exposed for testing to get the instance of `BTAPIClient`
    var apiClient: BTAPIClient
    
    // MARK: - Initializer
    
    /// Creates a `BTCreateCustomerSessionAPI`
    /// - Parameters:
    ///    - apiClient: A `BTAPIClient` instance
    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }
    
    /// This method will call the `CreateCustomerSession` GQL mutation, which returns a sessionId if successful.
    /// - Parameters:
    ///    - request: A `BTCustomerSessionRequest`
    ///    - completion: This completion will be invoked when the attempt to create a customer session is complete or an error occurs. On success, you will receive a sessionId; on failure you will receive an error.
    func execute(
        _ request: BTCustomerSessionRequest,
        completion: @escaping (String?, Error?) -> Void
    ) {
        do {
            let graphQLParams = try self.buildGraphQLDictionary(with: request)
            
            self.apiClient.post("", parameters: graphQLParams, httpType: .graphQLAPI) { body, _, error in
                if let error = error as? NSError {
                    completion(nil, error)
                    return
                }
                
                guard let body else {
                    completion(nil, BTShopperInsightsError.emptyBodyReturned)
                    return
                }
                
                guard let sessionId = body["data"]["createCustomerSession"]["sessionId"].asString() else {
                    completion(nil, BTHTTPError.httpResponseInvalid)
                    return
                }
                completion(sessionId, nil)
            }
        } catch {
            completion(nil, error)
        }
    }
    
    // MARK: - Helper Methods
    
    func buildGraphQLDictionary(with request: BTCustomerSessionRequest) throws -> [String: Any] {
        let inputParameters: [String: Any?] = [
            "customer": request.customer,
            "purchaseUnits": request.purchaseUnits
        ]
        let inputDictionary: [String: Any] = ["input": inputParameters]
        
        let graphQLParameters: [String: Any] = [
            "query":
                """
                mutation CreateCustomerSession($input: CreateCustomerSessionInput!) {
                    createCustomerSession(input: $input) {
                        sessionId
                    }
                }
                """,
            "variables": inputDictionary
        ]
        return graphQLParameters
    }
}
