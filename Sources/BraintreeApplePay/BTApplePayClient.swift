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
    /// - Parameter authorization: A client token or tokenization key
    @objc(initWithAuthorization:)
    public init(authorization: String) {
        self.apiClient = BTAPIClient(authorization: authorization)
    }

    // MARK: - Public Methods

    /// Creates a `PKPaymentRequest` with values from your Braintree Apple Pay configuration.
    /// It populates the following values of `PKPaymentRequest`: `countryCode`, `currencyCode`, `merchantIdentifier`, `supportedNetworks`.
    /// - Parameter completion: A completion block that returns the payment request or an error.
    @objc(makePaymentRequest:)
    public func makePaymentRequest(completion: @escaping (PKPaymentRequest?, Error?) -> Void) {
        Task { @MainActor in
            do {
                let paymentRequest = try await makePaymentRequest()
                completion(paymentRequest, nil)
            } catch {
                completion(nil, error)
            }
        }
    }

    /// Creates a `PKPaymentRequest` with values from your Braintree Apple Pay configuration.
    /// It populates the following values of `PKPaymentRequest`: `countryCode`, `currencyCode`, `merchantIdentifier`, `supportedNetworks`.
    /// - Returns: A `PKPaymentRequest`
    /// - Throws: An `Error` describing the failure
    public func makePaymentRequest() async throws -> PKPaymentRequest {
        apiClient.sendAnalyticsEvent(BTApplePayAnalytics.paymentRequestStarted)

        do {
            let configuration = try await apiClient.fetchOrReturnRemoteConfiguration()

            guard configuration.isApplePayEnabled else {
                sendPaymentRequestFailureAnalytics(with: BTApplePayError.unsupported)
                throw BTApplePayError.unsupported
            }

            let paymentRequest = PKPaymentRequest()
            paymentRequest.countryCode = configuration.applePayCountryCode ?? ""
            paymentRequest.currencyCode = configuration.applePayCurrencyCode ?? ""
            paymentRequest.merchantIdentifier = configuration.applePayMerchantIdentifier ?? ""
            paymentRequest.supportedNetworks = configuration.applePaySupportedNetworks ?? []

            return notifyPaymentRequestSuccess(with: paymentRequest)
        } catch {
            sendPaymentRequestFailureAnalytics(with: error)
            throw error
        }
    }

    /// Checks if Apple Pay is configured and available for the current merchant account and device.
    /// - Parameter completion: A completion block that returns `true` if Apple Pay is supported for the customer.
    @objc(isApplePaySupported:)
    public func isApplePaySupported(completion: @escaping (Bool) -> Void) {
        Task { @MainActor in
            let isSupported = await isApplePaySupported()
            completion(isSupported)
        }
    }

    /// Checks if Apple Pay is configured and available for the current merchant account and device.
    /// - Returns: A `Bool` that returns true if Apple Pay is supported for the customer.
    public func isApplePaySupported() async -> Bool {
        do {
            let configuration = try await apiClient.fetchOrReturnRemoteConfiguration()
            return configuration.canMakeApplePayPayments
        } catch {
            return false
        }
    }

    /// Tokenizes an Apple Pay payment.
    /// - Parameters:
    ///   - payment: A `PKPayment` instance, typically obtained by presenting a `PKPaymentAuthorizationViewController`
    ///   - completion: A completion block that is invoked when tokenization has completed. If tokenization succeeds, we will return a `BTApplePayCardNonce`
    ///   and `error` will be `nil`; if it fails, `BTApplePayCardNonce` will be `nil` and `error` will describe the failure.
    @objc(tokenizeApplePayPayment:completion:)
    public func tokenize(_ payment: PKPayment, completion: @escaping (BTApplePayCardNonce?, Error?) -> Void) {
        Task { @MainActor in
            do {
                let applePayNonce = try await tokenize(payment)
                completion(applePayNonce, nil)
            } catch {
                completion(nil, error)
            }
        }
    }

    /// Tokenizes an Apple Pay payment.
    /// - Parameter payment: A `PKPayment` instance, typically obtained by presenting a `PKPaymentAuthorizationViewController`
    /// - Returns: A `BTApplePayCardNonce`
    /// - Throws: An `Error` describing the failure
    public func tokenize(_ payment: PKPayment) async throws -> BTApplePayCardNonce {
        apiClient.sendAnalyticsEvent(BTApplePayAnalytics.tokenizeStarted)

        do {
            let configuration = try await apiClient.fetchOrReturnRemoteConfiguration()

            guard configuration.isApplePayEnabled else {
                sendTokenizeFailureAnalytics(with: BTApplePayError.unsupported)
                throw BTApplePayError.unsupported
            }

            let parameters = BTApplePaymentTokensRequest(token: payment.token)
            let (body, _) = try await apiClient.post("v1/payment_methods/apple_payment_tokens", parameters: parameters)

            guard let body else {
                sendTokenizeFailureAnalytics(with: BTApplePayError.noApplePayCardsReturned)
                throw BTApplePayError.noApplePayCardsReturned
            }

            guard let applePayNonce = BTApplePayCardNonce(json: body["applePayCards"][0]) else {
                sendTokenizeFailureAnalytics(with: BTApplePayError.failedToCreateNonce)
                throw BTApplePayError.failedToCreateNonce
            }

            return notifyTokenizeSuccess(with: applePayNonce)
        } catch {
            sendTokenizeFailureAnalytics(with: error)
            throw error
        }
    }
    
    // MARK: - Analytics Helper Methods

    private func notifyTokenizeSuccess(with result: BTApplePayCardNonce) -> BTApplePayCardNonce {
        apiClient.sendAnalyticsEvent(BTApplePayAnalytics.tokenizeSucceeded)
        return result
    }

    private func sendTokenizeFailureAnalytics(with error: Error) {
        apiClient.sendAnalyticsEvent(BTApplePayAnalytics.tokenizeFailed, errorDescription: error.localizedDescription)
    }

    private func notifyPaymentRequestSuccess(with result: PKPaymentRequest) -> PKPaymentRequest {
        apiClient.sendAnalyticsEvent(BTApplePayAnalytics.paymentRequestSucceeded)
        return result
    }

    private func sendPaymentRequestFailureAnalytics(with error: Error) {
        apiClient.sendAnalyticsEvent(BTApplePayAnalytics.paymentRequestFailed, errorDescription: error.localizedDescription)
    }
}
