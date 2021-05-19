import BraintreeCore
import BraintreePayPal
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

    func createOrder(with request: BTPayPalRequest & BTPayPalNativeRequest, completion: @escaping (Result<BTPayPalNativeOrder, BTPayPalNativeError>) -> Void) {
        apiClient.fetchOrReturnRemoteConfiguration { configuration, error in
            guard let config = configuration, error == nil else {
                completion(.failure(.fetchConfigurationFailed))
                return
            }

            guard config.json["paypalEnabled"].isTrue else {
                completion(.failure(.payPalNotEnabled))
                return
            }

            guard let payPalClientID = config.json["paypal"]["clientId"].asString() else {
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

            self.apiClient.post(request.hermesPath, parameters: request.parameters(with: config)) { json, response, error in
                guard let hermesResponse = BTPayPalNativeHermesResponse(json: json), error == nil else {
                    completion(.failure(.orderCreationFailed))
                    return
                }

                let order = BTPayPalNativeOrder(payPalClientID: payPalClientID,
                                                environment: environment,
                                                orderID: hermesResponse.orderID)
                completion(.success(order))
            }
        }
    }
}
