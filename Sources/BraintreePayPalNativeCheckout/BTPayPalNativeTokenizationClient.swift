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
        returnURL: String,
        completion: @escaping (Result<BTPayPalNativeCheckoutAccountNonce, BTPayPalNativeError>) -> Void)
    {

        let tokenizationRequest = BTPayPalNativeTokenizationRequest(
          request: request,
          correlationID: State.correlationIDs.riskCorrelationID ?? ""
        )

        apiClient.post(
            "v1/payment_methods/paypal_accounts",
            parameters: tokenizationRequest.parameters(returnURL: returnURL)
        ) { body, _, error in
            guard let json = body, error == nil else {
                let underlyingError = error ?? BTPayPalNativeError.invalidJSONResponse
                completion(.failure(.tokenizationFailed(underlyingError)))
                return
            }

            guard let accountNonce = BTPayPalNativeCheckoutAccountNonce(json: json) else {
                completion(.failure(.parsingTokenizationResultFailed))
                return
            }

            completion(.success(accountNonce))
        }
    }
}
