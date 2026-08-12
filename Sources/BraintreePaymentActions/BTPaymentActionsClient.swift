import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

@objc public class BTPaymentActionsClient: NSObject {
    
    // MARK: - Internal Properties
    
    /// Exposed for testing to get the instance of BTAPIClient
    var apiClient: BTAPIClient
    
    // MARK: - Initializer
    
    /// Creates a Payment Actions Client.
    /// - Parameter authorization: A valid client token or tokenization key used to authorize API calls.
    public init(authorization: String) {
        self.apiClient = BTAPIClient(authorization: authorization)
    }
    
    // MARK: - Public Methods
    
    /// Submits a payment method to a Payment Action.
    /// - Parameters:
    ///    - request: The payment method details to submit — e.g. a `BTCardPaymentActionRequest`.
    ///    - completion: A completion block that is invoked when the submission has completed. If it succeeds,
    ///    `status` will contain the resulting `BTPaymentActionStatus` and `error` will be `nil`; if it fails,
    ///    `error` will describe the failure.
    @objc(submitForPaymentAction:completion:)
    public func submitForPaymentAction(
        _ request: BTPaymentActionRequest,
        completion: @escaping (BTPaymentActionStatus, Error?) -> Void
    ) {
        Task { @MainActor in
            do {
                let status = try await submitForPaymentAction(request)
                completion(status, nil)
            } catch {
                completion(.unknown, error)
            }
        }
    }
    
    /// Submit a payment method for a Payment Action.
    /// - Parameter request: The payment method details to submit — e.g. a `BTCardPaymentActionRequest`.
    /// - Returns: the resulting `BTPaymentActionStatus`.
    /// - Throws: an `Error` describing the failure.
    public func submitForPaymentAction(
        _ request: BTPaymentActionRequest
    ) async throws -> BTPaymentActionStatus {
        try await submit(request)
    }
    
    // MARK: - Internal Methods
    
    /// Submits a payment method to the `setPaymentActionPaymentMethod` GraphQL mutation.
    /// - Parameter request: any payment-method-specific request subclassing `BTPaymentActionRequest`.
    /// - Returns: the resulting `BTPaymentActionStatus`.
    /// - Throws: the underlying error from the network layer or GraphQL response.
    func submit(_ request: BTPaymentActionRequest) async throws -> BTPaymentActionStatus {
        do {
            let body = SetPaymentActionPaymentMethodGraphQLBody(request: request)
            let result = try await setPaymentActionPaymentMethod(body)
            return result.status
        } catch {
            // TODO: Replace with the exact error type in a later PR.
            throw error
        }
    }
    
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
