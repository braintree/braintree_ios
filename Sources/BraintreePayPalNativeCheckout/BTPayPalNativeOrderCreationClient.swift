#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreePayPal)
import BraintreePayPal
#endif

import PayPalCheckout

struct BTPayPalNativeOrder: Equatable {

    let payPalClientID: String
    let environment: PayPalCheckout.Environment
    let orderID: String
}

@available(*, deprecated, message: "BraintreePayPalNativeCheckout Module is deprecated, use BraintreePayPal Module instead")
class BTPayPalNativeOrderCreationClient {

    var payPalContextID: String?

    private let apiClient: BTAPIClient

    init(with apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }

    func createOrder(
        with request: BTPayPalRequest,
        completion: @escaping (Result<BTPayPalNativeOrder, BTPayPalNativeCheckoutError>) -> Void
    ) {
        apiClient.fetchOrReturnRemoteConfiguration { configuration, error in
            guard let config = configuration, error == nil else {
                completion(.failure(.fetchConfigurationFailed))
                return
            }

            guard let paypalEnabled = config.json?["paypalEnabled"].isTrue, paypalEnabled else {
                completion(.failure(.payPalNotEnabled))
                return
            }

            guard let payPalClientID = config.json?["paypal"]["clientId"].asString() else {
                completion(.failure(.payPalClientIDNotFound))
                return
            }

            let payPalEnvironment: PayPalCheckout.Environment?
            if config.environment == "production" {
                payPalEnvironment = .live
            } else if config.environment == "sandbox" {
                payPalEnvironment = .sandbox
            } else {
                payPalEnvironment = nil
            }

            guard let environment = payPalEnvironment else {
                completion(.failure(.invalidEnvironment))
                return
            }

            self.apiClient.post(
                request.hermesPath,
                parameters: request.parameters(with: config)
            ) { json, _, error in
                guard let hermesResponse = BTPayPalNativeHermesResponse(json: json), error == nil else {
                    let underlyingError = error ?? BTPayPalNativeCheckoutError.invalidJSONResponse
                    completion(.failure(.orderCreationFailed(underlyingError)))
                    return
                }

                let order = BTPayPalNativeOrder(
                    payPalClientID: payPalClientID,
                    environment: environment,
                    orderID: hermesResponse.orderID
                )

                self.payPalContextID = order.orderID
                completion(.success(order))
            }
        }
    }
}
