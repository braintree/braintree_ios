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
        
        let paymentActionJSON: BTJSON = responseBody?["data"]["setPaymentActionPaymentMethod"]["paymentAction"] ?? BTJSON()
        
        // TODO: no error type currently exists for this service -- using NSError as a placeholder until the team decides how errors should be surfaced here.
        guard let paymentActionID = paymentActionJSON["id"].asString(), !paymentActionID.isEmpty else {
            throw NSError(
                domain: "com.braintreepayments.BTPaymentActionsErrorDomain",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Payment Action response is missing an id."]
            )
        }
        guard let statusString = paymentActionJSON["status"].asString(), !statusString.isEmpty else {
            throw NSError(
                domain: "com.braintreepayments.BTPaymentActionsErrorDomain",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Payment Action response is missing a status."]
            )
        }
        let status = BTPaymentActionStatus.status(from: statusString)
        return BTPaymentActionResult(id: paymentActionID, status: status)
    }
}
