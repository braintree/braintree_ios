import VisaCheckoutSDK
import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Creates a Visa Checkout client for processing Visa Checkout payments.
@objc public class BTVisaCheckoutClient: NSObject {

    private let apiClient: BTAPIClient

    /// Creates a Visa Checkout client.
    ///
    /// - Parameters:
    ///   - apiClient: An API client.
    @objc(initWithAPIClient:)
    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }

    /// Creates a Visa Checkout `Profile` with the merchant API key, environment, and other properties to be used with Visa Checkout.
    ///
    /// - Parameters:
    ///   - completion: A completion block that is invoked when the profile is created. If the profile creation succeeds,
    ///     `Profile` will contain a profile and `error` will be `nil`.
    ///     If it fails, `Profile` will be `nil` and `error` will describe the failure.
    @objc public func createProfile(completion: @escaping (Profile?, Error?) -> Void) {
        apiClient.fetchOrReturnRemoteConfiguration { configuration, error in
            if let error {
                completion(nil, error)
                return
            }

            guard let configuration else {
                completion(nil, BTVisaCheckoutError.fetchConfigurationFailed)
                return
            }

            guard configuration.isVisaCheckoutEnabled else {
                completion(nil, BTVisaCheckoutError.disabled)
                return
            }

            guard
                let visaCheckoutAPIKey = configuration.visaCheckoutAPIKey,
                let environmentString = configuration.visaCheckoutEnvironment,
                !environmentString.isEmpty else {
                completion(nil, BTVisaCheckoutError.integration)
                return
            }

            var environment: Environment = .sandbox

            if environmentString == "production" {
                environment = .production
            } else if environmentString == "sandbox" {
                environment = .sandbox
            } else {
                completion(nil, BTVisaCheckoutError.integration)
                return
            }

            let profile = Profile(
                environment: environment,
                apiKey: visaCheckoutAPIKey,
                profileName: nil
            )

            profile.datalevel = .full
            profile.clientId = configuration.visaCheckoutExternalClientID
            profile.acceptedCardBrands = configuration.acceptedCardBrands

            completion(profile, nil)
        }
    }

    /// Tokenizes a Visa checkout result.
    /// - Note: The `checkoutResult` parameter is declared as `callID` type, but you must pass a `CheckoutResult` instance.
    ///   `BTVisaCheckoutNonce` will contain a nonce and `error` will be `nil` if it fails
    ///   `BTVisaCheckoutNonce` will be `nil` and `error` will describe the failure.
    @objc public func tokenize(
        _ checkoutResult: CheckoutResult,
        completion: @escaping (BTVisaCheckoutNonce?, Error?) -> Void
    ) {
        apiClient.sendAnalyticsEvent(BTVisaCheckoutAnalytics.tokenizeStarted)

        let statusCode = checkoutResult.statusCode
        if statusCode == .statusUserCancelled {
            notifyFailure(with: BTVisaCheckoutError.canceled, completion: completion)
            return
        }

        guard statusCode == .statusSuccess else {
            notifyFailure(with: BTVisaCheckoutError.checkoutUnsuccessful, completion: completion)
            return
        }

        let callID = checkoutResult.callId
        let encryptedKey = checkoutResult.encryptedKey
        let encryptedPaymentData = checkoutResult.encryptedPaymentData

        tokenize(
            statusCode: statusCode,
            callID: callID,
            encryptedKey: encryptedKey,
            encryptedPaymentData: encryptedPaymentData,
            completion: completion
        )
    }

    func tokenize(
        statusCode: CheckoutResultStatus,
        callID: String?,
        encryptedKey: String?,
        encryptedPaymentData: String?,
        completion: @escaping (BTVisaCheckoutNonce?, Error?) -> Void
    ) {
        guard
            let callID = callID,
            let encryptedKey = encryptedKey,
            let encryptedPaymentData = encryptedPaymentData
        else {
            notifyFailure(with: BTVisaCheckoutError.integration, completion: completion)
            return
        }

        let parameters: [String: Any] = [
            "visaCheckoutCard": [
                "callId": callID,
                "encryptedKey": encryptedKey,
                "encryptedPaymentData": encryptedPaymentData
            ]
        ]

        apiClient.post("v1/payment_methods/visa_checkout_cards", parameters: parameters) { body, _, error in
            if let error {
                self.notifyFailure(with: error, completion: completion)
                return
            }

            guard let visaCheckoutCards = body?["visaCheckoutCards"].asArray()?.first else {
                self.notifyFailure(with: BTVisaCheckoutError.failedToCreateNonce, completion: completion)
                return
            }

            guard let visaCheckoutCardNonce = BTVisaCheckoutNonce(json: visaCheckoutCards) else {
                self.notifyFailure(with: BTVisaCheckoutError.failedToCreateNonce, completion: completion)
                return
            }

            self.notifySuccess(with: visaCheckoutCardNonce, completion: completion)
        }
    }

    // MARK: - Analytics Helper Methods

    /// Notifies the success of the Visa Checkout tokenization.
    private func notifySuccess(
        with result: BTVisaCheckoutNonce?,
        completion: @escaping (BTVisaCheckoutNonce?, Error?) -> Void
    ) {
        apiClient.sendAnalyticsEvent(BTVisaCheckoutAnalytics.tokenizeSucceeded)
        completion(result, nil)
    }
    
    /// Notifies the failure of the Visa Checkout tokenization.
    private func notifyFailure(with error: Error, completion: @escaping (BTVisaCheckoutNonce?, Error?) -> Void) {
        apiClient.sendAnalyticsEvent(BTVisaCheckoutAnalytics.tokenizeFailed, errorDescription: error.localizedDescription)
        completion(nil, error)
    }
}
