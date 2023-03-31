import Foundation
import PassKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Used to process Apple Pay payments
@objc public class BTApplePayClient: NSObject {

    // MARK: - Internal Properties

    /// Exposed for testing to get the instance of BTAPIClient
    var apiClient: BTAPIClient

    // MARK: - Initializer

    /// Creates an Apple Pay client
    /// - Parameter apiClient: An API client
    @objc(initWithAPIClient:)
    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }

    // MARK: - Public Methods

    /// Creates a `PKPaymentRequest` with values from your Braintree Apple Pay configuration.
    /// It populates the following values of `PKPaymentRequest`: `countryCode`, `currencyCode`, `merchantIdentifier`, `supportedNetworks`.
    /// - Parameter completion: A completion block that returns the payment request or an error.
    @objc(makePaymentRequest:)
    public func makePaymentRequest(completion: @escaping (PKPaymentRequest?, Error?) -> Void) {
        apiClient.fetchOrReturnRemoteConfiguration { [weak self] configuration, error in
            guard let self else { return }
            
            if let error {
                self.apiClient.sendAnalyticsEvent("ios.apple-pay.error.configuration")
                self.completionHandler(onMainThreadWithPaymentRequest: nil, error: error, completion: completion)
                return
            }

            guard let configuration, configuration.isApplePayEnabled else {
                self.apiClient.sendAnalyticsEvent("ios.apple-pay.error.disabled")
                self.completionHandler(onMainThreadWithPaymentRequest: nil, error: BTApplePayError.unsupported, completion: completion)
                return
            }

            let paymentRequest = PKPaymentRequest()
            paymentRequest.countryCode = configuration.applePayCountryCode ?? ""
            paymentRequest.currencyCode = configuration.applePayCurrencyCode ?? ""
            paymentRequest.merchantIdentifier = configuration.applePayMerchantIdentifier ?? ""
            paymentRequest.supportedNetworks = configuration.applePaySupportedNetworks ?? []

            self.completionHandler(onMainThreadWithPaymentRequest: paymentRequest, error: nil, completion: completion)
        }
    }

    /// Creates a `PKPaymentRequest` with values from your Braintree Apple Pay configuration.
    /// It populates the following values of `PKPaymentRequest`: `countryCode`, `currencyCode`, `merchantIdentifier`, `supportedNetworks`.
    /// - Returns: A `PKPaymentRequest`
    /// - Throws: An `Error` describing the failure
    public func makePaymentRequest() async throws -> PKPaymentRequest {
        try await withCheckedThrowingContinuation { continuation in
            makePaymentRequest() { paymentRequest, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let paymentRequest {
                    continuation.resume(returning: paymentRequest)
                }
            }
        }
    }

    /// Tokenizes an Apple Pay payment.
    /// - Parameters:
    ///   - payment: A `PKPayment` instance, typically obtained by presenting a `PKPaymentAuthorizationViewController`
    ///   - completion: A completion block that is invoked when tokenization has completed. If tokenization succeeds, we will return a `BTApplePayCardNonce`
    ///   and `error` will be `nil`; if it fails, `BTApplePayCardNonce` will be `nil` and `error` will describe the failure.
    @objc(tokenizeApplePayPayment:completion:)
    public func tokenize(_ payment: PKPayment, completion: @escaping (BTApplePayCardNonce?, Error?) -> Void) {
        apiClient.sendAnalyticsEvent("ios.apple-pay.start")

        apiClient.fetchOrReturnRemoteConfiguration { [weak self] configuration, error in
            guard let self else { return }
            
            if let error {
                self.apiClient.sendAnalyticsEvent("ios.apple-pay.error.configuration")
                completion(nil, error)
                return
            }

            guard let configuration, configuration.isApplePayEnabled else {
                self.apiClient.sendAnalyticsEvent("ios.apple-pay.error.disabled")
                completion(nil, BTApplePayError.unsupported)
                return
            }

            let metaParameters: [String: String] = [
                "source": self.apiClient.metadata.sourceString,
                "integration": self.apiClient.metadata.integrationString,
                "sessionId": self.apiClient.metadata.sessionID
            ]

            let parameters: [String: Any] = [
                "applePaymentToken": self.parametersForPaymentToken(token: payment.token),
                "_meta": metaParameters
            ]

            self.apiClient.post("v1/payment_methods/apple_payment_tokens", parameters: parameters) { body, _, error in
                if let error = error as NSError? {
                    if error.code == BTCoreConstants.networkConnectionLostCode {
                        self.apiClient.sendAnalyticsEvent("ios.apple-pay.network-connection.failure")
                    }

                    self.apiClient.sendAnalyticsEvent("ios.apple-pay.error.tokenization")
                    completion(nil, error)
                    return
                }

                guard let body else {
                    completion(nil, BTApplePayError.noApplePayCardsReturned)
                    return
                }

                guard let applePayNonce: BTApplePayCardNonce = BTApplePayCardNonce(json: body["applePayCards"][0]) else {
                    completion(nil, BTApplePayError.failedToCreateNonce)
                    return
                }

                completion(applePayNonce, nil)
                self.apiClient.sendAnalyticsEvent("ios.apple-pay.success")
            }
        }
    }

    /// Tokenizes an Apple Pay payment.
    /// - Parameter payment: A `PKPayment` instance, typically obtained by presenting a `PKPaymentAuthorizationViewController`
    /// - Returns: A `BTApplePayCardNonce`
    /// - Throws: An `Error` describing the failure
    public func tokenize(_ payment: PKPayment) async throws -> BTApplePayCardNonce {
        try await withCheckedThrowingContinuation { continuation in
            tokenize(payment) { applePayNonce, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let applePayNonce {
                    continuation.resume(returning: applePayNonce)
                }
            }
        }
    }

    // MARK: - Internal Methods

    func parametersForPaymentToken(token: PKPaymentToken) -> [String: Any?] {
        [
            "paymentData": token.paymentData.base64EncodedString(),
            "transactionIdentifier": token.transactionIdentifier,
            "paymentInstrumentName": token.paymentMethod.displayName,
            "paymentNetwork": token.paymentMethod.network
        ]
    }

    func completionHandler(
        onMainThreadWithPaymentRequest paymentRequest: PKPaymentRequest?,
        error: Error?,
        completion: @escaping (PKPaymentRequest?, Error?) -> Void
    ) {
        DispatchQueue.main.async {
            completion(paymentRequest, error)
        }
    }
}
