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

    /// Creates a Visa Checkout profile.
    /// - Parameters:
    ///   - completion: A completion block that is invoked when the profile is created.
    ///   `profile` will be an instance of VisaProfile when successful, otherwise `nil`.
    ///   `error` will be the related error if VisaProfile could not be created, otherwise `nil`.
    @objc public func createProfile(completion: @escaping (Profile?, Error?) -> Void) {
        apiClient.fetchOrReturnRemoteConfiguration { configuration, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let configuration = configuration, configuration.isVisaCheckoutEnabled else {
                let error = BTVisaCheckoutError.unsupported
                completion(nil, error)
                return
            }

            let environmentString = configuration.visaCheckoutEnvironment
            let environment: Environment = (environmentString == "sandbox") ? .sandbox : .production

            let profile = Profile(
                environment: environment,
                apiKey: configuration.visaCheckoutAPIKey ?? "",
                profileName: nil
            )
            profile.datalevel = .full
            profile.clientId = configuration.visaCheckoutExternalClientID
            profile.acceptedCardBrands = configuration.visaCheckoutSupportedNetworks

            completion(profile, nil)
        }
    }

    /// Tokenizes a Visa checkout result.
    /// - Note: The `checkoutResult` parameter is declared as `callID` type, but you must pass a `VisaCheckoutResult` instance.
    /// - Parameters:
    ///   - checkoutResult: A Visa `CheckoutResult` instance.
    ///   - completion: A completion block that is invoked when tokenization has completed. If tokenization succeeds,
    ///   `tokenizedVisaCheckoutCard` will contain a nonce and `error` will be `nil`; if it fails
    ///   `tokenizedVisaCheckoutCard` will be `nil` and `error` will describe the failure.
    @objc public func tokenizeVisaCheckoutResult(
        _ checkoutResult: CheckoutResult,
        completion: @escaping (BTVisaCheckoutNonce?, Error?) -> Void
    ) {
        let statusCode = checkoutResult.statusCode
        let callID = checkoutResult.callId
        let encryptedKey = checkoutResult.encryptedKey
        let encryptedPaymentData = checkoutResult.encryptedPaymentData

        tokenizeVisaCheckoutResult(
            statusCode: statusCode,
            callID: callID,
            encryptedKey: encryptedKey,
            encryptedPaymentData: encryptedPaymentData,
            completion: completion
        )
    }

    /// Tokenizes a Visa checkout result. Exposed for testing properties of the Visa `CheckoutResult`
    /// - Parameters:
    ///   - statusCode: The result code indicating the status of a completed Visa Checkout transaction.
    ///   - callId: The unique identifier for the Visa Checkout transaction.
    ///   - encryptedKey: The encrypted key associated with the Visa Checkout transaction.
    ///   - encryptedPaymentData: The encrypted payment data for the Visa Checkout transaction.
    ///   - completion: A completion block that is invoked when tokenization has completed.
    @objc public func tokenizeVisaCheckoutResult(
        statusCode: CheckoutResultStatus,
        callID: String?,
        encryptedKey: String?,
        encryptedPaymentData: String?,
        completion: @escaping (BTVisaCheckoutNonce?, Error?) -> Void
    ) {
        if statusCode == .statusUserCancelled {
            sendAnalyticsAndComplete("ios.visacheckout.result.cancelled", result: nil, error: nil, completion: completion)
            return
        }

        guard statusCode == .statusSuccess else {
            let analyticEvent = analyticsEvent(for: statusCode)
            let error = "Visa Checkout failed with status code \(statusCode.rawValue)"
            sendAnalyticsAndComplete(
                BTVisaCheckoutAnalytics.tokenizeFailed + ": \(analyticEvent)",
                result: nil,
                error: error as? Error,
                completion: completion
            )
            return
        }

        guard let callId = callID, let encryptedKey = encryptedKey, let encryptedPaymentData = encryptedPaymentData else {
            let error = BTVisaCheckoutError.integration
            sendAnalyticsAndComplete("ios.visacheckout.result.failed.invalid-payment", result: nil, error: error, completion: completion)
            return
        }

        let parameters: [String: Any] = [
            "visaCheckoutCard": [
                "callId": callId,
                "encryptedKey": encryptedKey,
                "encryptedPaymentData": encryptedPaymentData
            ]
        ]

        apiClient.post("v1/payment_methods/visa_checkout_cards", parameters: parameters) { body, _, error in
            if let error {
                self.notifyFailure(with: error, completion: completion)
                return
            }

            else {
                self.notifyFailure(with: BTVisaCheckoutError.unknown, completion: completion)
                return
            }
            self.sendAnalyticsAndComplete(BTVisaCheckoutAnalytics.tokenizeSucceeded, result: nil, error: error, completion: completion)
        }
    }

    // MARK: - Analytics Helper Methods

    private func notifyFailure(with error: Error, completion: @escaping (BTVisaCheckoutNonce?, Error) -> Void) {
        apiClient.sendAnalyticsEvent(
            BTVisaCheckoutAnalytics.tokenizeFailed,
            errorDescription: error.localizedDescription
        )
        completion(nil, error)
    }

    private func sendAnalyticsAndComplete(
        _ event: String,
        result: BTVisaCheckoutNonce?,
        error: Error?,
        completion: @escaping (BTVisaCheckoutNonce?, Error?) -> Void
    ) {
        apiClient.sendAnalyticsEvent(event)
        completion(result, error)
    }

    private func analyticsEvent(for status: CheckoutResultStatus) -> String {
        switch status {
        case .statusDuplicateCheckoutAttempt:
            return "duplicate-checkouts-open"
        case .statusNotConfigured:
            return "not-configured"
        case .statusInternalError:
            return "internal-error"
        case .statusNetworkError:
            return "network-error"
        default:
            return "unknown"
        }
    }
}
