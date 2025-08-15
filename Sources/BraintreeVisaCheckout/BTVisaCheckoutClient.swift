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
        let statusCode = checkoutResult.statusCode
        let callID = checkoutResult.callId
        let encryptedKey = checkoutResult.encryptedKey
        let encryptedPaymentData = checkoutResult.encryptedPaymentData

        if statusCode == .statusUserCancelled {
            completion(nil, BTVisaCheckoutError.canceled)
            return
        }

        guard statusCode == .statusSuccess else {
            completion(nil, BTVisaCheckoutError.checkoutUnsuccessful)
            return
        }

        guard let encryptedKey, let encryptedPaymentData else {
            completion(nil, BTVisaCheckoutError.integration)
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
                completion(nil, error)
                return
            }

            guard let visaCheckoutCards = body?["visaCheckoutCards"].asArray()?.first else {
                completion(nil, BTVisaCheckoutError.failedToCreateNonce)
                return
            }

            guard let visaCheckoutCardNonce = BTVisaCheckoutNonce(json: visaCheckoutCards) else {
                completion(nil, BTVisaCheckoutError.failedToCreateNonce)
                return
            }

            completion(visaCheckoutCardNonce, nil)
            return
        }
    }
}
