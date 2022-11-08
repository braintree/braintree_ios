#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreeCoreSwift)
import BraintreeCoreSwift
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

class BTPayPalNativeOrderCreationClient {

    private let apiClient: BTAPIClient

    init(with apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }

    func createOrder(
        with request: BTPayPalRequest & BTPayPalNativeRequest,
        completion: @escaping (Result<BTPayPalNativeOrder, BTPayPalNativeError>) -> Void
    ) {
        apiClient.fetchOrReturnRemoteConfiguration { configuration, error in
            guard let config = configuration, error == nil else {
                completion(.failure(.fetchConfigurationFailed))
                return
            }

            guard let paypalEnabled = config.json?["paypalEnabled"].isTrue, paypalEnabled else {
                self.apiClient.sendAnalyticsEvent("ios.paypal-native.create-order.paypal-not-enabled.failed")
                completion(.failure(.payPalNotEnabled))
                return
            }

            guard let payPalClientID = config.json?["paypal"]["clientId"].asString() else {
                self.apiClient.sendAnalyticsEvent("ios.paypal-native.create-order.client-id-not-found.failed")
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
                self.apiClient.sendAnalyticsEvent("ios.paypal-native.create-order.invalid-environment.failed")
                completion(.failure(.invalidEnvironment))
                return
            }

            self.apiClient.post(
                request.hermesPath,
                parameters: request.parameters(with: config) as? [String: Any]
            ) { json, response, error in
                guard let hermesResponse = BTPayPalNativeHermesResponse(json: json), error == nil else {
                    let underlyingError = error ?? BTPayPalNativeError.invalidJSONResponse
                    self.apiClient.sendAnalyticsEvent("ios.paypal-native.create-order.hermes-url-request.failed")
                    completion(.failure(.orderCreationFailed(underlyingError)))
                    return
                }

                let order = BTPayPalNativeOrder(
                    payPalClientID: payPalClientID,
                    environment: environment,
                    orderID: hermesResponse.orderID
                )

                self.apiClient.sendAnalyticsEvent("ios.paypal-native.create-order.succeeded")
                completion(.success(order))
            }
        }
    }
}
