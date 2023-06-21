#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreePayPal)
import BraintreePayPal
#endif

import PayPalCheckout

class BTPayPalNativeTokenizationClient {

    private let apiClient: BTAPIClient

    init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }

    func tokenize(
        request: BTPayPalRequest,
        approvalData: ApprovalData,
        completion: @escaping (Result<BTPayPalNativeCheckoutAccountNonce, BTPayPalNativeCheckoutError>) -> Void)
    {

        let tokenizationRequest = BTPayPalNativeTokenizationRequest(
          request: request,
          correlationID: request.riskCorrelationID ?? State.correlationIDs.riskCorrelationID ?? ""
        )

        apiClient.post(
            "v1/payment_methods/paypal_accounts",
            parameters: tokenizationRequest.parameters(returnURL: approvalData.returnURL!.absoluteString)
        ) { body, _, error in
            guard let json = body, error == nil else {
                let underlyingError = error ?? BTPayPalNativeCheckoutError.invalidJSONResponse
                completion(.failure(.tokenizationFailed(underlyingError)))
                return
            }

            guard let accountNonce = BTPayPalNativeCheckoutAccountNonce(json: json, approvalData: approvalData) else {
                completion(.failure(.parsingTokenizationResultFailed))
                return
            }
            
            completion(.success(accountNonce))
        }
    }
}
