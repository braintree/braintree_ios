import VisaCheckoutSDK
import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

// Creates a Visa Checkout client for processing Visa Checkout payments.
public class BTVisaCheckoutClient {

    private let apiClient: BTAPIClient

    /// Creates a Visa Checkout client.
    ///
    /// - Parameters:
    ///   - apiClient: An API client.
    @objc(initWithAPIClient:)
    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }

    /// Creates a Visa Checkout `ProfileBuilder` with the merchant API key, environment, and other properties to be used with Visa Checkout.
    ///
    /// - Parameters:
    ///   - completion: A completion block that is invoked when the profile is created.
    ///
    /// In addition to setting the `merchantApiKey` and `environment` the other properties that Braintree will fill in on the ProfileBuilder are:
    ///   - dataLevel: Required to be [Profile.DataLevel.FULL] for Braintree to access card details
    ///   - clientId: Allows the encrypted payload to be processable by Braintree.
    ///   - acceptedCardBrands: A list of Card brands that your merchant account can transact.
    @objc public func createProfileBuilder(completion: @escaping (Profile?, Error?) -> Void) {
        apiClient.fetchOrReturnRemoteConfiguration { configuration, error in
            if let error {
                /// TODO: Add failure analytics event
                completion(nil, error)
                return
            }

            guard let configuration else {
                /// TODO: Add `fetchConfigurationFailed` analytics event
                completion(nil, error)
                return
            }

            guard configuration.isVisaCheckoutEnabled else {
                /// TODO: Add failure analytics Visa Checkout not enabled
                return
            }

            let environmentString = configuration.visaCheckoutEnvironment
            let environment: Environment = environmentString == "sandbox" ? .sandbox : .production

            let profile = Profile(
                environment: environment,
                apiKey: configuration.visaCheckoutAPIKey ?? "",
                profileName: nil
            )
            profile.datalevel = .full
            profile.clientId = configuration.visaCheckoutExternalClientID
            profile.acceptedCardBrands = configuration.acceptedCardBrands

            completion(profile, nil)
        }
    }

    /// Tokenizes a Visa checkout result.
    /// - Note: The `checkoutResult` parameter is declared as `callID` type, but you must pass a `VisaCheckoutResult` instance.
    /// - Parameters:
    ///   - checkoutResult: A Visa `CheckoutResult` instance.
    ///   - completion: A completion block that is invoked when tokenization has completed. If tokenization succeeds,
    ///   - statusCode: The result code indicating the status of a completed Visa Checkout transaction.
    ///   - callId: The unique identifier for the Visa Checkout transaction.
    ///   - encryptedKey: The encrypted key associated with the Visa Checkout transaction.
    ///   - encryptedPaymentData: The encrypted payment data for the Visa Checkout transaction.
    ///   `BTVisaCheckoutNonce` will contain a nonce and `error` will be `nil` if it fails
    ///   `BTVisaCheckoutNonce` will be `nil` and `error` will describe the failure.
    @objc public func visaPaymentSummary(
        _ checkoutResult: CheckoutResult,
        completion: @escaping (BTVisaCheckoutNonce?, Error?) -> Void
    ) {
        let statusCode = checkoutResult.statusCode

        if statusCode == .statusUserCancelled {
            return
        }

        guard statusCode == .statusSuccess else {
            /// TODO: Add error code
            return
        }
    }
}
