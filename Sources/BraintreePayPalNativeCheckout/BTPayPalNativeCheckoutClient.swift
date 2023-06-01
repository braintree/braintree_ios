import Foundation

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

    // MARK: - Public Methods

    /// Tokenize a PayPal request to be used with the PayPal Native Checkout flow.
    ///
    /// On success, you will receive an instance of `BTPayPalNativeCheckoutAccountNonce`.
    /// On failure or user cancelation you will receive an error. If the user cancels
    /// out of the flow, the error code will equal `BTPayPalNativeError.canceled.rawValue`.
    /// 
    /// - Parameters:
    ///   - request: A `BTPayPalNativeCheckoutRequest`
    ///   - completion: The completion will be invoked exactly once: when tokenization is complete or an error occurs.
    @objc(tokenizeWithNativeCheckoutRequest:completion:)
    public func tokenize(
        _ request: BTPayPalNativeCheckoutRequest,
        completion: @escaping (BTPayPalNativeCheckoutAccountNonce?, Error?) -> Void
    ) {
        tokenize(request: request, completion: completion)
    }

    /// Tokenize a PayPal request to be used with the PayPal Native Checkout flow.
    ///
    /// On success, you will receive an instance of `BTPayPalNativeCheckoutAccountNonce`.
    /// On failure or user cancelation you will receive an error. If the user cancels
    /// out of the flow, the error code will equal `BTPayPalNativeError.canceled.rawValue`.
    ///
    /// - Parameter request: A `BTPayPalNativeCheckoutRequest`
    /// - Returns: A `BTPayPalNativeCheckoutAccountNonce` if successful
    /// - Throws: An `Error` describing the failure
    public func tokenize(_ request: BTPayPalNativeCheckoutRequest) async throws -> BTPayPalNativeCheckoutAccountNonce {
        try await withCheckedThrowingContinuation { continuation in
            tokenize(request) { nonce, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let nonce {
                    continuation.resume(returning: nonce)
                }
            }
        }
    }

    /// Tokenize a PayPal request to be used with the PayPal Native Vault flow.
    ///
    /// On success, you will receive an instance of `BTPayPalNativeCheckoutAccountNonce`.
    /// On failure or user cancelation you will receive an error. If the user cancels
    /// out of the flow, the error code will equal `BTPayPalNativeError.canceled.rawValue`.
    ///
    /// - Parameters:
    ///   - request: A `BTPayPalNativeVaultRequest`
    ///   - completion: The completion will be invoked exactly once: when tokenization is complete or an error occurs.
    @objc(tokenizeWithNativeVaultRequest:completion:)
    public func tokenize(
        _ request: BTPayPalNativeVaultRequest,
        completion: @escaping (BTPayPalNativeCheckoutAccountNonce?, Error?) -> Void
    ) {
        tokenize(request: request, completion: completion)
    }

    /// Tokenize a PayPal request to be used with the PayPal Native Vault flow.
    ///
    /// On success, you will receive an instance of `BTPayPalNativeCheckoutAccountNonce`.
    /// On failure or user cancelation you will receive an error. If the user cancels
    /// out of the flow, the error code will equal `BTPayPalNativeError.canceled.rawValue`.
    ///
    /// - Parameter request: A `BTPayPalNativeVaultRequest`
    /// - Returns: A `BTPayPalNativeCheckoutAccountNonce` if successful
    /// - Throws: An `Error` describing the failure
    public func tokenize(_ request: BTPayPalNativeVaultRequest) async throws -> BTPayPalNativeCheckoutAccountNonce {
        try await withCheckedThrowingContinuation { continuation in
            tokenize(request) { nonce, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let nonce {
                    continuation.resume(returning: nonce)
                }
            }
        }
    }

    // MARK: - Private Methods

    private func tokenize(
        request: BTPayPalRequest,
        completion: @escaping (BTPayPalNativeCheckoutAccountNonce?, Error?) -> Void
    ) {
        self.apiClient.sendAnalyticsEvent(BTPayPalNativeCheckoutAnalytics.tokenizeStarted)
        let orderCreationClient = BTPayPalNativeOrderCreationClient(with: apiClient)
        orderCreationClient.createOrder(with: request) { [weak self] result in
            guard let self else { return }

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
                            self.notifyFailure(with: BTPayPalNativeError.invalidRequest, completion: completion)

                        }
                    },
                    onApprove: { [weak self] approval in
                        guard let self else { return }

                        tokenize(approval: approval, request: request, completion: completion)
                    },
                    onCancel: {
                        self.notifyCancel(completion: completion)
                    },
                    onError: { error in
                        self.notifyFailure(with: BTPayPalNativeError.checkoutSDKFailed, completion: completion)
                    },
                    environment: order.environment
                )

                PayPalCheckout.Checkout.showsExitAlert = false
                PayPalCheckout.Checkout.set(config: payPalNativeConfig)
                
                NotificationCenter.default.post(name: Notification.Name("brain_tree_source_event"), object: nil)
              
                PayPalCheckout.Checkout.start()
            case .failure(let error):
                apiClient.sendAnalyticsEvent(BTPayPalNativeCheckoutAnalytics.orderCreationFailed)
                notifyFailure(with: error, completion: completion)
            }
        }
    }

    private func tokenize(
        approval: PayPalCheckout.Approval,
        request: BTPayPalRequest,
        completion: @escaping (BTPayPalNativeCheckoutAccountNonce?, Error?) -> Void
    ) {
        let tokenizationClient = BTPayPalNativeTokenizationClient(apiClient: apiClient)
        tokenizationClient.tokenize(request: request, returnURL: approval.data.returnURL!.absoluteString) { result in
            switch result {
            case .success(let nonce):
                self.notifySuccess(with: nonce, completion: completion)
            case .failure(let error):
                self.notifyFailure(with: error, completion: completion)
            }
        }
    }

    // MARK: - Analytics Helper Methods

    private func notifySuccess(
        with result: BTPayPalNativeCheckoutAccountNonce,
        completion: @escaping (BTPayPalNativeCheckoutAccountNonce?, Error?) -> Void
    ) {
        apiClient.sendAnalyticsEvent(BTPayPalNativeCheckoutAnalytics.tokenizeSucceeded)
        completion(result, nil)
    }

    private func notifyFailure(with error: Error, completion: @escaping (BTPayPalNativeCheckoutAccountNonce?, Error?) -> Void) {
        apiClient.sendAnalyticsEvent(
            BTPayPalNativeCheckoutAnalytics.tokenizeFailed,
            errorDescription: error.localizedDescription
        )
        completion(nil, error)
    }

    private func notifyCancel(completion: @escaping (BTPayPalNativeCheckoutAccountNonce?, Error?) -> Void) {
        self.apiClient.sendAnalyticsEvent(BTPayPalNativeCheckoutAnalytics.tokenizeCanceled)
        completion(nil, BTPayPalNativeError.canceled)
    }
}
