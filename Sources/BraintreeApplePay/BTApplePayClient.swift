import Foundation
import PassKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Used to process Apple Pay payments
@objcMembers public class BTApplePayClient_Swift: NSObject {

    //MARK: - Internal Properties

    /// Exposed for testing to get the instance of BTAPIClient
    var apiClient: BTAPIClient

    // MARK: - Initializer

    /// Creates an Apple Pay client
    /// - Parameter apiClient: An API client
    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }

    // MARK: - Public Methods

    public func paymentRequest(completion: @escaping (PKPaymentRequest?, Error?) -> Void) {
        apiClient.fetchOrReturnRemoteConfiguration { configuration, error in
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

    // TODO: remove Obj-C files, run tests, run demo app, update Package.swift + podspec + add changelog entry

    @objc(tokenizeApplePayPayment:completion:)
    public func tokenize(_ payment: PKPayment, completion: @escaping (BTApplePayCardNonce?, Error?) -> Void) {
        apiClient.sendAnalyticsEvent("ios.apple-pay.start")

        apiClient.fetchOrReturnRemoteConfiguration { configuration, error in
            if let error {
                self.apiClient.sendAnalyticsEvent("ios.apple-pay.error.configuration")
                completion(nil, error)
                return
            }

            if let configuration,
               configuration.json?["applePay"]["status"].isString == false ||
               configuration.json?["applePay"]["status"].asString() == "off" {
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
