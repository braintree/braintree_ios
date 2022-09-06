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
                self.apiClient.sendAnalyticsEvent("ios.paypal-native-checkout.create-order.fetch-configuration.failure")
                completion(.failure(.fetchConfigurationFailed))
                return
            }

            guard config.json["paypalEnabled"].isTrue else {
                self.apiClient.sendAnalyticsEvent("ios.paypal-native-checkout.create-order.paypal-not-enabled.failure")
                completion(.failure(.payPalNotEnabled))
                return
            }

            guard let payPalClientID = config.json["paypal"]["clientId"].asString() else {
                self.apiClient.sendAnalyticsEvent("ios.paypal-native-checkout.create-order.client-id-not-found.failure")
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
                self.apiClient.sendAnalyticsEvent("ios.paypal-native-checkout.create-order.invalid-environment.failure")
                completion(.failure(.invalidEnvironment))
                return
            }

            self.apiClient.post(
                request.hermesPath,
                parameters: request.parameters(with: config)
            ) { json, response, error in
                guard let hermesResponse = BTPayPalNativeHermesResponse(json: json), error == nil else {
                    let underlyingError = error ?? BTPayPalNativeError.invalidJSONResponse
                    self.apiClient.sendAnalyticsEvent("ios.paypal-native-checkout.create-order.order-creation.failure")
                    completion(.failure(.orderCreationFailed(underlyingError)))
                    return
                }

                let order = BTPayPalNativeOrder(
                    payPalClientID: payPalClientID,
                    environment: environment,
                    orderID: hermesResponse.orderID
                )

                self.apiClient.sendAnalyticsEvent("ios.paypal-native-checkout.create-order.success")
                completion(.success(order))
            }
        }
    }
}
