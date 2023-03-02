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
