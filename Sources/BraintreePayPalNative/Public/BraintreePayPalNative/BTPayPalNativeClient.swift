import BraintreeCore
import BraintreePayPal
import PayPalCheckout

@objc public class BTPayPalNativeClient: NSObject {

    // MARK: - Public

    /**
     Initializes a PayPal Native client.

     - Parameter apiClient: The Braintree API client

     - Returns: A PayPal Native client
     */
    @objc(initWithAPIClient:)
    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }

    /**
     Tokenize a PayPal account for vault or checkout. On success, you will receive an instance of `BTPayPalNativeAccountNonce`. On failure or user cancelation you will receive an error. If the user cancels out of the flow, the error code will equal `BTPayPalNativeError.canceled.rawValue`.

     - Parameter request Either a BTPayPalNativeCheckoutRequest or a BTPayPalNativeVaultRequest

     - Parameter completion The completion will be invoked exactly once: when tokenization is complete or an error occurs.
    */
    @objc(tokenizePayPalAccountWithPayPalRequest:completion:)
    public func tokenizePayPalAccount(with nativeRequest: BTPayPalRequest, completion: @escaping (BTPayPalNativeAccountNonce?, NSError?) -> Void) {
        guard let request = nativeRequest as? (BTPayPalRequest & BTPayPalNativeRequest) else {
            completion(nil, BTPayPalNativeError.invalidRequest as NSError)
            return
        }

        let orderCreationClient = BTPayPalNativeOrderCreationClient(with: apiClient)
        orderCreationClient.createOrder(with: request) { result in
            switch result {
            case .success(let order):
                let payPalNativeConfig = PayPalCheckout.CheckoutConfig(clientID: order.payPalClientID,
                                                                       returnUrl: request.payPalReturnURL,
                                                                       createOrder: nil,
                                                                       onApprove: nil,
                                                                       onCancel: nil,
                                                                       onError: nil,
                                                                       environment: order.environment)

                PayPalCheckout.Checkout.set(config: payPalNativeConfig)

                PayPalCheckout.Checkout.start(presentingViewController: nil, createOrder: { action in
                    action.set(orderId: order.orderID)
                }, onApprove: { approval in

                }, onCancel: {

                }, onError: { error in

                })
            case .failure(let error):
                completion(nil, error as NSError)
            }
        }
    }

    // MARK: - Private
    private let apiClient: BTAPIClient
}
