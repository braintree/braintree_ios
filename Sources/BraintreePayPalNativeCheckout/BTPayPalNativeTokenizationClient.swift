#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreePayPal)
import BraintreePayPal
#endif

import PayPalCheckout

@available(*, deprecated, message: "BraintreePayPalNativeCheckout Module is deprecated, use BraintreePayPal Module instead")
class BTPayPalNativeTokenizationClient {

    private let apiClient: BTAPIClient

    init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }

    func tokenize(
        request: BTPayPalRequest,
        returnURL: String?,
        buyerData: User? = nil,
        completion: @escaping (Result<BTPayPalNativeCheckoutAccountNonce, BTPayPalNativeCheckoutError>) -> Void
    ) {
        guard let returnURL else {
            completion(.failure(.missingReturnURL))
            return
        }

        let tokenizationRequest = BTPayPalNativeTokenizationRequest(
            request: request,
            correlationID: request.riskCorrelationID ?? State.correlationIDs.riskCorrelationID ?? ""
        )

        apiClient.post(
            "v1/payment_methods/paypal_accounts",
            parameters: tokenizationRequest.parameters(returnURL: returnURL)
        ) { body, _, error in
            guard let json = body, error == nil else {
                let underlyingError = error ?? BTPayPalNativeCheckoutError.invalidJSONResponse
                completion(.failure(.tokenizationFailed(underlyingError)))
                return
            }

            guard let accountNonce = BTPayPalNativeCheckoutAccountNonce(json: json, buyerData: buyerData) else {
                completion(.failure(.parsingTokenizationResultFailed))
                return
            }

            completion(.success(accountNonce))
        }
    }
}
