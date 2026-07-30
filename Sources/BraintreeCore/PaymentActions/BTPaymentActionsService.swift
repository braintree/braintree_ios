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
    /// - Parameter body: the GraphQL request body to submit, encoding the payment method details and the fields
    /// to return on the `paymentAction` selection set.
    /// - Returns: a `BTPaymentActionResult` containing the Payment Action `id` and `status`.
    /// - Throws: `BTPaymentActionsError.customerInputInvalid` if the server returns a 422 with an invalid-input message, or the underlying error otherwise.
    func setPaymentMethod<Body: BTGraphQLEncodableBody>(_ body: Body) async throws -> BTPaymentActionResult {
        
        let responseBody: BTJSON?
        
        do {
            (responseBody, _) = try await apiClient.post("", parameters: body, httpType: .graphQLAPI)
        } catch let error as NSError {
            if error.domain == BTCoreConstants.httpErrorDomain,
            error as? BTHTTPError == .clientError([:]),
            let urlResponse = error.userInfo[BTCoreConstants.urlResponseKey] as? HTTPURLResponse,
            urlResponse.statusCode == 422 {
                var userInfo: [String: Any] = error.userInfo
                let errorBody = error.userInfo[BTCoreConstants.jsonResponseBodyKey] as? BTJSON
                
                if let message = errorBody?["error"]["message"], message.isString {
                    userInfo[NSLocalizedDescriptionKey] = message.asString() as Any
                }
                
                throw BTPaymentActionsError.customerInputInvalid(userInfo)
            }
            throw error
        }
        
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
