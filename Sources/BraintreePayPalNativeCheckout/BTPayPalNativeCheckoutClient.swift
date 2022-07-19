#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreePayPal)
import BraintreePayPal
#endif

import PayPalCheckout

/// Client used to collect PayPal payment methods. If possible, this client will present a native flow; otherwise, it will fall back to a web flow.
@objc public class BTPayPalNativeCheckoutClient: NSObject {

    private let apiClient: BTAPIClient

    ///  Initializes a PayPal Native client.
    /// - Parameter apiClient: The Braintree API client
    @objc(initWithAPIClient:)
    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }

    /// Tokenize a PayPal account for vault or checkout. On success, you will receive an instance of
    /// `BTPayPalNativeCheckoutAccountNonce`. On failure or user cancelation you will receive an error. If the user cancels
    /// out of the flow, the error code will equal `BTPayPalNativeError.canceled.rawValue`.
    /// - Parameters:
    ///   - nativeRequest: Either a BTPayPalNativeCheckoutRequest or a BTPayPalNativeVaultRequest
    ///   - completion: The completion will be invoked exactly once: when tokenization is complete or an error occurs.
    @objc(tokenizePayPalAccountWithPayPalRequest:completion:)
    public func tokenizePayPalAccount(
        with nativeRequest: BTPayPalRequest,
        completion: @escaping (BTPayPalNativeCheckoutAccountNonce?, Error?) -> Void
    ) {
        guard let request = nativeRequest as? (BTPayPalRequest & BTPayPalNativeRequest) else {
            completion(nil, BTPayPalNativeError.invalidRequest)
            return
        }

        let orderCreationClient = BTPayPalNativeOrderCreationClient(with: apiClient)
        orderCreationClient.createOrder(with: request) { [weak self] result in
            switch result {
            case .success(let order):
                let payPalNativeConfig = PayPalCheckout.CheckoutConfig(
                    clientID: order.payPalClientID,
                    createOrder: { action in
                        switch request.paymentType {
                        case .checkout:
                            action.set(orderId: order.orderID)
                        case .vault:
                            action.set(billingAgreementToken: order.orderID)
                        @unknown default:
                            completion(nil, BTPayPalNativeError.invalidRequest)
                        }
                    },
                    onApprove: { [weak self] approval in
                        self?.tokenize(approval: approval, request: request, completion: completion)
                    },
                    onCancel: {
                        completion(nil, BTPayPalNativeError.canceled)
                    },
                    onError: { error in
                        completion(nil, BTPayPalNativeError.checkoutSDKFailed)
                    },
                    environment: order.environment
                )

                PayPalCheckout.Checkout.set(config: payPalNativeConfig)
                PayPalCheckout.Checkout.start()
            case .failure(let error):
                completion(nil, error)
            }
        }
    }

    private func tokenize(approval: PayPalCheckout.Approval, request: BTPayPalRequest, completion: @escaping (BTPayPalNativeCheckoutAccountNonce?, Error?) -> Void) {
        let tokenizationClient = BTPayPalNativeTokenizationClient(apiClient: apiClient)
        tokenizationClient.tokenize(request: request, returnURL: approval.data.returnURL!.absoluteString) { result in
            switch result {
            case .success(let nonce):
                completion(nonce, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}
