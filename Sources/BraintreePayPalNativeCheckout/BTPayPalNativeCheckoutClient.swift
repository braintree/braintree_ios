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
    ///   - request: Either a BTPayPalNativeCheckoutRequest or a BTPayPalNativeVaultRequest
    ///   - completion: The completion will be invoked exactly once: when tokenization is complete or an error occurs.
    @objc(tokenizePayPalAccountWithPayPalRequest:completion:)
    public func tokenizePayPalAccount(
        with request: BTPayPalNativeRequest,
        completion: @escaping (BTPayPalNativeCheckoutAccountNonce?, Error?) -> Void
    ) {
        apiClient.sendAnalyticsEvent("ios.paypal-native.tokenize.started")

        let orderCreationClient = BTPayPalNativeOrderCreationClient(with: apiClient)
        orderCreationClient.createOrder(with: request) { [weak self] result in
            switch result {
            case .success(let order):
                self?.apiClient.sendAnalyticsEvent("ios.paypal-native.create-order.started")
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
                        self?.apiClient.sendAnalyticsEvent("ios.paypal-native.on-approve.started")
                        self?.tokenize(approval: approval, request: request, completion: completion)
                    },
                    onCancel: {
                        self?.apiClient.sendAnalyticsEvent("ios.paypal-native.canceled")
                        completion(nil, BTPayPalNativeError.canceled)
                    },
                    onError: { error in
                        self?.apiClient.sendAnalyticsEvent("ios.paypal-native.on-error.failed")
                        completion(nil, BTPayPalNativeError.checkoutSDKFailed)
                    },
                    environment: order.environment
                )

                PayPalCheckout.Checkout.showsExitAlert = false
                PayPalCheckout.Checkout.set(config: payPalNativeConfig)
                
                NotificationCenter.default.post(name: Notification.Name("brain_tree_source_event"), object: nil)
              
                PayPalCheckout.Checkout.start()
            case .failure(let error):
                self?.apiClient.sendAnalyticsEvent("ios.paypal-native.create-order.failed")
                completion(nil, error)
            }
        }
    }

    private func tokenize(approval: PayPalCheckout.Approval, request: BTPayPalNativeRequest, completion: @escaping (BTPayPalNativeCheckoutAccountNonce?, Error?) -> Void) {
        let tokenizationClient = BTPayPalNativeTokenizationClient(apiClient: apiClient)
        tokenizationClient.tokenize(request: request, returnURL: approval.data.returnURL!.absoluteString) { result in
            switch result {
            case .success(let nonce):
                self.apiClient.sendAnalyticsEvent("ios.paypal-native.on-approve.succeeded")
                completion(nonce, nil)
            case .failure(let error):
                self.apiClient.sendAnalyticsEvent("ios.paypal-native.on-approve.failed")
                completion(nil, error)
            }
        }
    }
}
