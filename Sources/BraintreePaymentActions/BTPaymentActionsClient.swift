import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

@objc public class BTPaymentActionsClient: NSObject {

    private static let errorDomain = "com.braintreepayments.BTPaymentActionsErrorDomain"

    private let apiClient: BTAPIClient

    public init(authorization: String) {
        self.apiClient = BTAPIClient(authorization: authorization)
    }

    // MARK: - Public Methods

    /// Submits a payment method to a Payment Action.
    /// - Parameter request: the payment method-specific request to submit, e.g. `BTCardPaymentActionRequest`.
    /// - Returns: the resulting `BTPaymentActionStatus` after the payment method has been set.
    /// - Throws: an error if the network request fails or the GraphQL response is missing required fields.
    @nonobjc public func submitForPaymentAction(_ request: any BTPaymentActionRequest) async throws -> BTPaymentActionStatus {
        let body = graphQLBody(for: request)
        let result = try await setPaymentActionPaymentMethod(body)
        return result.status
    }

    // MARK: - Private Methods

    /// Submits a payment method to the `setPaymentActionPaymentMethod` GraphQL mutation.
    /// - Parameter body: the GraphQL request body to submit, encoding the payment method
    ///   details and the fields to return on the `paymentAction` selection set.
    /// - Returns: a `BTPaymentActionResult` containing the Payment Action `id` and `status`.
    /// - Throws: the underlying error from the network layer or GraphQL response.
    private func setPaymentActionPaymentMethod<Body: BTGraphQLEncodableBody>(
        _ body: Body
    ) async throws -> BTPaymentActionResult {
        let (responseBody, _) = try await apiClient.post("", parameters: body, httpType: .graphQLAPI)

        let paymentActionJSON: BTJSON = responseBody?["data"]["setPaymentActionPaymentMethod"]["paymentAction"] ?? BTJSON()

        // TODO: no error type currently exists for this service -- using NSError as a placeholder until the team decides how errors should be surfaced here.
        guard let paymentActionID = paymentActionJSON["id"].asString(), !paymentActionID.isEmpty else {
            throw NSError(
                domain: Self.errorDomain,
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Payment Action response is missing an id."]
            )
        }
        guard let statusString = paymentActionJSON["status"].asString(), !statusString.isEmpty else {
            throw NSError(
                domain: Self.errorDomain,
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Payment Action response is missing a status."]
            )
        }
        let status = BTPaymentActionStatus.status(from: statusString)
        return BTPaymentActionResult(id: paymentActionID, status: status)
    }

    private func graphQLBody(for request: any BTPaymentActionRequest) -> BTSetPaymentActionPaymentMethodBody {
        BTSetPaymentActionPaymentMethodBody(
            variables: .init(
                input: .init(
                    paymentActionId: request.paymentActionID,
                    paymentMethod: AnyEncodable(request.paymentMethodParameters())
                )
            )
        )
    }

    private struct BTSetPaymentActionPaymentMethodBody: BTGraphQLEncodableBody {

        let query = """
        mutation SetPaymentActionPaymentMethod($input: SetPaymentActionPaymentMethodInput!) {
          setPaymentActionPaymentMethod(input: $input) {
            paymentAction {
              id
              status
            }
          }
        }
        """

        let variables: Variables

        struct Variables: Encodable {

            let input: Input

            struct Input: Encodable {
                let paymentActionId: String
                let paymentMethod: AnyEncodable
            }
        }
    }
}
