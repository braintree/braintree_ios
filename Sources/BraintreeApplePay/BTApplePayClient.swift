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
        apiClient.sendAnalyticsEvent(BTApplePayAnalytics.paymentRequestStarted)

        apiClient.fetchOrReturnRemoteConfiguration { configuration, error in
            if let error {
                self.apiClient.sendAnalyticsEvent(BTApplePayAnalytics.paymentRequestFailed)
                completion(nil, error)
                return
            }

            guard let configuration, configuration.isApplePayEnabled else {
                self.apiClient.sendAnalyticsEvent(BTApplePayAnalytics.paymentRequestFailed)
                completion(nil, BTApplePayError.unsupported)
                return
            }

            let paymentRequest = PKPaymentRequest()
            paymentRequest.countryCode = configuration.applePayCountryCode ?? ""
            paymentRequest.currencyCode = configuration.applePayCurrencyCode ?? ""
            paymentRequest.merchantIdentifier = configuration.applePayMerchantIdentifier ?? ""
            paymentRequest.supportedNetworks = configuration.applePaySupportedNetworks ?? []

            self.apiClient.sendAnalyticsEvent(BTApplePayAnalytics.paymentRequestSucceeded)
            completion(paymentRequest, nil)
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
        apiClient.sendAnalyticsEvent(BTApplePayAnalytics.tokenizeStarted)

        apiClient.fetchOrReturnRemoteConfiguration { configuration, error in
            if let error {
                self.apiClient.sendAnalyticsEvent(BTApplePayAnalytics.tokenizeFailed)
                completion(nil, error)
                return
            }

            guard let configuration, configuration.isApplePayEnabled else {
                self.apiClient.sendAnalyticsEvent(BTApplePayAnalytics.tokenizeFailed)
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
                        self.apiClient.sendAnalyticsEvent(BTApplePayAnalytics.tokenizeNetworkConnectionLost)
                    }

                    self.apiClient.sendAnalyticsEvent(BTApplePayAnalytics.tokenizeFailed)
                    completion(nil, error)
                    return
                }

                guard let body else {
                    self.apiClient.sendAnalyticsEvent(BTApplePayAnalytics.tokenizeFailed)
                    completion(nil, BTApplePayError.noApplePayCardsReturned)
                    return
                }

                guard let applePayNonce: BTApplePayCardNonce = BTApplePayCardNonce(json: body["applePayCards"][0]) else {
                    self.apiClient.sendAnalyticsEvent(BTApplePayAnalytics.tokenizeFailed)
                    completion(nil, BTApplePayError.failedToCreateNonce)
                    return
                }

                self.apiClient.sendAnalyticsEvent(BTApplePayAnalytics.tokenizeSucceeded)
                completion(applePayNonce, nil)
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
}
