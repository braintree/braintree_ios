import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreePayPal)
import BraintreePayPal
#endif

import PayPalCheckout

@available(*, deprecated, message: "BraintreePayPalNativeCheckout Module is deprecated, use BraintreePayPal Module instead")
/// Client used to collect PayPal payment methods. If possible, this client will present a native flow; otherwise, it will fall back to a web flow.
@objc public class BTPayPalNativeCheckoutClient: NSObject {

    private let apiClient: BTAPIClient
    
    /// Used in POST body for FPTI analytics.
    private var clientMetadataID: String?

    /// Used for linking events from the client to server side request
    /// In the PayPal Native Checkout flow this will be an Order ID
    private var payPalContextID: String?

    private let nativeCheckoutProvider: BTPayPalNativeCheckoutStartable


    @available(*, deprecated, message: "BraintreePayPalNativeCheckout Module is deprecated, use BraintreePayPal Module instead")
    ///  Initializes a PayPal Native client.
    /// - Parameter apiClient: The Braintree API client
    @objc(initWithAPIClient:)
    public convenience init(apiClient: BTAPIClient) {
        self.init(apiClient: apiClient, nativeCheckoutProvider: BTPayPalNativeCheckoutProvider())
    }

    init(apiClient: BTAPIClient, nativeCheckoutProvider: BTPayPalNativeCheckoutStartable) {
        self.apiClient = apiClient
        self.nativeCheckoutProvider = nativeCheckoutProvider
    }

    // MARK: - Public Methods

    @available(*, deprecated, message: "BraintreePayPalNativeCheckout Module is deprecated, use BraintreePayPal Module instead")
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
        tokenize(request: request, userAuthenticationEmail: request.userAuthenticationEmail, completion: completion)
    }

    @available(*, deprecated, message: "BraintreePayPalNativeCheckout Module is deprecated, use BraintreePayPal Module instead")
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

    @available(*, deprecated, message: "BraintreePayPalNativeCheckout Module is deprecated, use BraintreePayPal Module instead")
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

    @available(*, deprecated, message: "BraintreePayPalNativeCheckout Module is deprecated, use BraintreePayPal Module instead")
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
        userAuthenticationEmail: String? = nil,
        completion: @escaping (BTPayPalNativeCheckoutAccountNonce?, Error?) -> Void
    ) {
        clientMetadataID = request.riskCorrelationID ?? State.correlationIDs.riskCorrelationID
        self.apiClient.sendAnalyticsEvent(BTPayPalNativeCheckoutAnalytics.tokenizeStarted)
        
        let orderCreationClient = BTPayPalNativeOrderCreationClient(with: apiClient)

        orderCreationClient.createOrder(with: request) { [weak self] result in
            guard let self else {
                completion(nil, BTPayPalNativeCheckoutError.deallocated)
                return
            }

            if let payPalContextID = orderCreationClient.payPalContextID, !payPalContextID.isEmpty {
                self.payPalContextID = payPalContextID
            }

            switch result {
            case .success(let order):
                let nxoConfig = CheckoutConfig(clientID: order.payPalClientID, environment: order.environment)
                nxoConfig.authConfig.userEmail = userAuthenticationEmail

                nativeCheckoutProvider.start(request: request, order: order, nxoConfig: nxoConfig) { returnURL, buyerData in
                    self.tokenize(returnURL: returnURL, buyerData: buyerData, request: request, completion: completion)
                } onStartableCancel: {
                    self.notifyCancel(completion: completion)
                } onStartableError: { error in
                    self.notifyFailure(with: error, completion: completion)
                }

            case .failure(let error):
                notifyFailure(with: error, completion: completion)
            }
        }
    }

    private func tokenize(
        returnURL: String?,
        buyerData: User? = nil,
        request: BTPayPalRequest,
        completion: @escaping (BTPayPalNativeCheckoutAccountNonce?, Error?) -> Void
    ) {
        let tokenizationClient = BTPayPalNativeTokenizationClient(apiClient: apiClient)
        tokenizationClient.tokenize(request: request, returnURL: returnURL, buyerData: buyerData) { result in
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
        apiClient.sendAnalyticsEvent(
            BTPayPalNativeCheckoutAnalytics.tokenizeSucceeded,
            correlationID: clientMetadataID,
            payPalContextID: payPalContextID
        )
        completion(result, nil)
    }

    private func notifyFailure(with error: Error, completion: @escaping (BTPayPalNativeCheckoutAccountNonce?, Error?) -> Void) {
        apiClient.sendAnalyticsEvent(
            BTPayPalNativeCheckoutAnalytics.tokenizeFailed,
            correlationID: clientMetadataID,
            errorDescription: error.localizedDescription,
            payPalContextID: payPalContextID
        )
        completion(nil, error)
    }

    private func notifyCancel(completion: @escaping (BTPayPalNativeCheckoutAccountNonce?, Error?) -> Void) {
        self.apiClient.sendAnalyticsEvent(
            BTPayPalNativeCheckoutAnalytics.tokenizeCanceled,
            correlationID: clientMetadataID,
            payPalContextID: payPalContextID
        )
        completion(nil, BTPayPalNativeCheckoutError.canceled)
    }
}
