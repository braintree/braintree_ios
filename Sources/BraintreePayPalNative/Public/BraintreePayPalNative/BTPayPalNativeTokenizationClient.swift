import BraintreeCore
import PayPalCheckout
import BraintreePayPal

class BTPayPalNativeTokenizationClient {

    private let apiClient: BTAPIClient

    init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }

    func tokenize(returnURL: String,
                  request: BTPayPalRequest,
                  completion: @escaping (Result<BTPayPalNativeAccountNonce, BTPayPalNativeError>) -> Void) {

        // TODO: Add unit tests for this scenario. Also do a sweep of all unit testing for PayPalNative module.
        guard let correlationID = State.correlationIDs.riskCorrelationID else {
            completion(.failure(.riskCorrelationIDNotFound))
            return
        }

        let tokenizationRequest = BTPayPalNativeTokenizationRequest(returnURL: returnURL,
                                                                    request: request,
                                                                    correlationID: correlationID,
                                                                    clientMetadata: apiClient.metadata)

        apiClient.post("/v1/payment_methods/paypal_accounts", parameters: tokenizationRequest.parameters()) { body, _, error in
            guard let json = body, error == nil else {
                completion(.failure(.tokenizationFailed))
                return
            }

            guard let accountNonce = BTPayPalNativeAccountNonce(json: json) else {
                completion(.failure(.parsingTokenizationResultFailed))
                return
            }

            completion(.success(accountNonce))
        }
    }
}
