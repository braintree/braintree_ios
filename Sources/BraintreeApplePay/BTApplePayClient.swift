import Foundation
import PassKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Used to process Apple Pay payments
@objcMembers public class BTApplePayClient: NSObject {

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

    @objc(paymentRequest:)
    public func paymentRequest(completion: @escaping (PKPaymentRequest?, Error?) -> Void) {
        self.apiClient.sendAnalyticsEvent("apple-pay:payment-request:started")
        apiClient.fetchOrReturnRemoteConfiguration { configuration, error in
            if let error {
                self.apiClient.sendAnalyticsEvent("apple-pay:payment-request:failed")
                self.completionHandler(onMainThreadWithPaymentRequest: nil, error: error, completion: completion)
                return
            }

            guard let configuration, configuration.isApplePayEnabled else {
                self.apiClient.sendAnalyticsEvent("apple-pay:payment-request:failed")
                self.completionHandler(onMainThreadWithPaymentRequest: nil, error: BTApplePayError.unsupported, completion: completion)
                return
            }

            let paymentRequest = PKPaymentRequest()
            paymentRequest.countryCode = configuration.applePayCountryCode ?? ""
            paymentRequest.currencyCode = configuration.applePayCurrencyCode ?? ""
            paymentRequest.merchantIdentifier = configuration.applePayMerchantIdentifier ?? ""
            paymentRequest.supportedNetworks = configuration.applePaySupportedNetworks ?? []

            self.apiClient.sendAnalyticsEvent("apple-pay:payment-request:succeeded")
            self.completionHandler(onMainThreadWithPaymentRequest: paymentRequest, error: nil, completion: completion)
        }
    }

    @objc(tokenizeApplePayPayment:completion:)
    public func tokenize(_ payment: PKPayment, completion: @escaping (BTApplePayCardNonce?, Error?) -> Void) {
        apiClient.sendAnalyticsEvent("apple-pay:tokenize:started")

        apiClient.fetchOrReturnRemoteConfiguration { configuration, error in
            if let error {
                self.apiClient.sendAnalyticsEvent("apple-pay:tokenize:failed")
                completion(nil, error)
                return
            }

            guard let configuration, configuration.isApplePayEnabled else {
                self.apiClient.sendAnalyticsEvent("apple-pay:tokenize:failed")
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
                        self.apiClient.sendAnalyticsEvent("apple-pay:tokenize:network-connection:failed")
                    } else {
                        self.apiClient.sendAnalyticsEvent("apple-pay:tokenize:failed")
                    }

                    completion(nil, error)
                    return
                }

                guard let body else {
                    self.apiClient.sendAnalyticsEvent("apple-pay:tokenize:failed")
                    completion(nil, BTApplePayError.noApplePayCardsReturned)
                    return
                }

                guard let applePayNonce: BTApplePayCardNonce = BTApplePayCardNonce(json: body["applePayCards"][0]) else {
                    self.apiClient.sendAnalyticsEvent("apple-pay:tokenize:failed")
                    completion(nil, BTApplePayError.failedToCreateNonce)
                    return
                }

                completion(applePayNonce, nil)
                self.apiClient.sendAnalyticsEvent("apple-pay:tokenize:succeeded")
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
