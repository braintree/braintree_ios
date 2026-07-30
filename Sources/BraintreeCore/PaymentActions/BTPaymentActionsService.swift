import Foundation

class BTPaymentActionsService {
    
    // MARK: - Internal Properties
    
    private let apiClient: BTAPIClient
    
    // MARK: - Initializer
    
    init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }
    
    // MARK: - Internal Methods
    
    /// Submits a payment method to the `setPaymentActionPaymentMethod` GraphQL mutation.
    /// - Parameter body: the GraphQL request body to submit, encoding the payment method
    ///   details and the fields to return on the `paymentAction` selection set.
    /// - Returns: a `BTPaymentActionResult` containing the Payment Action `id` and `status`.
    /// - Throws: the underlying error from the network layer or GraphQL response.
    func setPaymentActionPaymentMethod<Body: BTGraphQLEncodableBody>(
        _ body: Body
    ) async throws -> BTPaymentActionResult {
        let (responseBody, _) = try await apiClient.post("", parameters: body, httpType: .graphQLAPI)
        
        let setPaymentActionPaymentMethodJSON: BTJSON = responseBody?["data"]["setPaymentActionPaymentMethod"] ?? BTJSON()
        
        if let jsonError = setPaymentActionPaymentMethodJSON.asError() {
            throw jsonError
        }
        
        let paymentActionJSON: BTJSON = setPaymentActionPaymentMethodJSON["paymentAction"]
        let paymentActionID = paymentActionJSON["id"].asString() ?? ""
        let status = BTPaymentActionStatus.status(from: paymentActionJSON["status"].asString() ?? "")
        
        return BTPaymentActionResult(id: paymentActionID, status: status)
    }
}
