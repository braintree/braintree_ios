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

            var paymentRequest = PKPaymentRequest()
            paymentRequest.countryCode = configuration.applePayCountryCode ?? ""
            paymentRequest.currencyCode = configuration.applePayCurrencyCode ?? ""
            paymentRequest.merchantIdentifier = configuration.applePayMerchantIdentifier ?? ""
            paymentRequest.supportedNetworks = configuration.applePaySupportedNetworks ?? []

            self.completionHandler(onMainThreadWithPaymentRequest: paymentRequest, error: nil, completion: completion)
        }
    }

    // TODO: tokenizeApplePayPayment, remove Obj-C files, run tests, run demo app, update Package.swift + podspec

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
