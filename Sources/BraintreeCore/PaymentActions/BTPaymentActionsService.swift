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
        
        do {
            let (body, _) = try await apiClient.post("", parameters: body, httpType: .graphQLAPI)
            
            let paymentActionJSON: BTJSON = body?["data"]["setPaymentActionPaymentMethod"]["paymentAction"] ?? BTJSON()
            
            // TODO: Verify and ensure these error types are correct in a later PR.
            guard let paymentActionID = paymentActionJSON["id"].asString(), !paymentActionID.isEmpty else {
                throw BTPaymentActionError.missingID
            }
            guard let statusString = paymentActionJSON["status"].asString(), !statusString.isEmpty else {
                throw BTPaymentActionError.missingStatus
            }
            let status = BTPaymentActionStatus.status(from: statusString)
            return BTPaymentActionResult(id: paymentActionID, status: status)
        } catch {
            // TODO: Replace with exact error type in a later PR.
            throw error
        }
    }
}
