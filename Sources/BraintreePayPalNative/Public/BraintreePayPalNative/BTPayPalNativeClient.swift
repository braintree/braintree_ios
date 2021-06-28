import BraintreeCore
import BraintreePayPal
import PayPalCheckout

/**
 Client used to collect PayPal payment methods. If possible, this client will present a native flow; otherwise, it will fall back to a web flow.
 */
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
        orderCreationClient.createOrder(with: request) { [weak self] result in
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
                PayPalCheckout.Checkout.showsExitAlert = false

                PayPalCheckout.Checkout.start(presentingViewController: nil, createOrder: { action in
                    if request is BTPayPalNativeCheckoutRequest {
                        action.set(orderId: order.orderID)
                    } else if request is BTPayPalNativeVaultRequest {
                        action.set(billingAgreementToken: order.orderID)
                    }
                }, onApprove: { [weak self] approval in
                    self?.tokenize(approval: approval, request: request, completion: completion)
                }, onCancel: {
                    completion(nil, BTPayPalNativeError.canceled as NSError)
                    return
                }, onError: { error in
                    completion(nil, BTPayPalNativeError.checkoutSDKFailed as NSError)
                    return
                })
            case .failure(let error):
                completion(nil, error as NSError)
                return
            }
        }
    }

    // MARK: - Private

    private let apiClient: BTAPIClient

    private func tokenize(approval: PayPalCheckout.Approval, request: BTPayPalRequest, completion: @escaping (BTPayPalNativeAccountNonce?, NSError?) -> Void) {
        guard let returnURL = approval.data.returnURL?.absoluteString else {
            completion(nil, BTPayPalNativeError.returnURLNotFound as NSError)
            return
        }

        let tokenizationClient = BTPayPalNativeTokenizationClient(apiClient: apiClient)
        tokenizationClient.tokenize(returnURL: returnURL, request: request) { result in
            switch result {
            case .success(let nonce):
                completion(nonce, nil)
            case .failure(let error):
                completion(nil, error as NSError)
            }
        }
    }
}
