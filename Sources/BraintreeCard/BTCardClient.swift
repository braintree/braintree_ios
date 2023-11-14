import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Used to process cards
@objc public class BTCardClient: NSObject {

    // MARK: - Internal Properties

    /// Exposed for testing to get the instance of BTAPIClient
    let apiClient: BTAPIClient

    let graphQLTokenizeFeature: String = "tokenize_credit_cards"

    // MARK: - Initializer

    /// Creates a card client
    /// - Parameter apiClient: An API client
    @objc(initWithAPIClient:)
    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }

    // MARK: - Public Methods

    /// Tokenizes a card
    /// - Parameters:
    ///    - card: The card to tokenize.
    ///    - completion: A completion block that is invoked when card tokenization has completed. If tokenization succeeds,
    ///    `tokenize` will contain a nonce and `error` will be `nil`; if it fails, `tokenize` will be `nil` and `error`will describe the failure.
    @objc(tokenizeCard:completion:)
    public func tokenize(_ card: BTCard, completion: @escaping (BTCardNonce?, Error?) -> Void) {
        apiClient.sendAnalyticsEvent(BTCardAnalytics.cardTokenizeStarted)

        apiClient.fetchOrReturnRemoteConfiguration() { configuration, error in
            if let error {
                self.notifyFailure(with: error, completion: completion)
                return
            }
            
            guard let configuration else {
                self.notifyFailure(with: BTCardError.fetchConfigurationFailed, completion: completion)
                return
            }

            if self.isGraphQLEnabled(for: configuration) {
                if card.authenticationInsightRequested && card.merchantAccountID == nil {
                    self.notifyFailure(with: BTCardError.integration, completion: completion)
                    return
                }

                let parameters = card.graphQLParameters()

                self.apiClient.post("", parameters: parameters, httpType: .graphQLAPI) { body, _, error in
                    if let error = error as NSError? {
                        let response: HTTPURLResponse? = error.userInfo[BTCoreConstants.urlResponseKey] as? HTTPURLResponse
                        var callbackError: Error? = error

                        if response?.statusCode == 422 {
                            callbackError = self.constructCallbackError(with: error.userInfo, error: error)
                        }

                        self.notifyFailure(with: callbackError ?? error, completion: completion)
                        return
                    }

                    let cardJSON: BTJSON = body?["data"]["tokenizeCreditCard"] ?? BTJSON()

                    if let cardJSONError = cardJSON.asError() {
                        self.notifyFailure(with: cardJSONError, completion: completion)
                        return
                    }

                    let cardNonce: BTCardNonce = BTCardNonce(graphQLJSON: cardJSON)

                    self.notifySuccess(with: cardNonce, completion: completion)
                    return
                }
            } else {
                let parameters = self.clientAPIParameters(for: card)

                self.apiClient.post("v1/payment_methods/credit_cards", parameters: parameters) {body, _, error in
                    if let error = error as NSError? {
                        let response: HTTPURLResponse? = error.userInfo[BTCoreConstants.urlResponseKey] as? HTTPURLResponse
                        var callbackError: Error? = error

                        if response?.statusCode == 422 {
                            callbackError = self.constructCallbackError(with: error.userInfo, error: error)
                        }

                        self.notifyFailure(with: callbackError ?? error, completion: completion)
                        return
                    }

                    let cardJSON: BTJSON = body?["creditCards"][0] ?? BTJSON()

                    if let cardJSONError = cardJSON.asError() {
                        self.notifyFailure(with: cardJSONError, completion: completion)
                        return
                    }

                    let cardNonce: BTCardNonce = BTCardNonce(json: cardJSON)

                    self.notifySuccess(with: cardNonce, completion: completion)
                    return
                }
            }
        }
    }

    /// Tokenizes a card
    /// - Parameter card: The card to tokenize.
    /// - Returns: On success, you will receive an instance of `BTCardNonce`
    /// - Throws: An `Error` describing the failure
    public func tokenize(_ card: BTCard) async throws -> BTCardNonce {
        try await withCheckedThrowingContinuation { continuation in
            tokenize(card) { nonce, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let nonce {
                    continuation.resume(returning: nonce)
                }
            }
        }
    }

    // MARK: - Private Methods

    private func isGraphQLEnabled(for configuration: BTConfiguration) -> Bool {
        if let graphQLFeatures = configuration.json?["graphQL"]["features"].asStringArray() {
            return !graphQLFeatures.isEmpty && graphQLFeatures.contains(graphQLTokenizeFeature)
        }

        return false
    }

    private func clientAPIParameters(for card: BTCard) -> [String: Any] {
        var parameters: [String: Any] = [:]
        parameters["credit_card"] = card.parameters()

        let metadata: [String: String] = [
            "source": apiClient.metadata.source.stringValue,
            "integration": apiClient.metadata.integration.stringValue,
            "sessionId": apiClient.metadata.sessionID
        ]

        parameters["_meta"] = metadata

        if card.authenticationInsightRequested {
            parameters["authenticationInsight"] = true
            parameters["merchantAccountId"] = card.merchantAccountID
        }

        return parameters
    }

    // MARK: - Error Construction Methods

    /// Convenience helper method for creating friendlier, more human-readable userInfo dictionaries for 422 HTTP errors
    private func validationError(with userInfo: [String: Any]) -> [String: Any] {
        var finalUserInfo: [String: Any] = userInfo
        let jsonResponse: BTJSON? = userInfo[BTCoreConstants.jsonResponseBodyKey] as? BTJSON

        if let jsonDictionary = jsonResponse?.asDictionary() {
            finalUserInfo["BTCustomerInputBraintreeValidationErrorsKey"] = jsonDictionary
        }

        if let errorMessage = jsonResponse?["error"]["message"].asString() {
            finalUserInfo[NSLocalizedDescriptionKey] = errorMessage
        }

        let fieldError: BTJSON? = jsonResponse?["fieldErrors"].asArray()?.first
        let firstFieldError: BTJSON? = fieldError?["fieldErrors"].asArray()?.first

        if let firstFieldErrorMessage = firstFieldError?["message"].asString() {
            finalUserInfo[NSLocalizedFailureReasonErrorKey] = firstFieldErrorMessage
        }

        return finalUserInfo
    }

    private func constructCallbackError(with errorUserInfo: [String: Any]?, error: NSError?) -> Error? {
        let errorResponse: BTJSON? = error?.userInfo[BTCoreConstants.jsonResponseBodyKey] as? BTJSON
        let fieldErrors: BTJSON? = errorResponse?["fieldErrors"].asArray()?.first

        var errorCode: BTJSON? = fieldErrors?["fieldErrors"].asArray()?.first?["code"]
        var callbackError: Error? = error

        if errorCode == nil {
            let errorResponse: BTJSON? = errorUserInfo?[BTCoreConstants.jsonResponseBodyKey] as? BTJSON
            errorCode = errorResponse?["errors"].asArray()?.first?["extensions"]["legacyCode"]
        }

        // Gateway error code for card already exists
        if errorCode?.asString() == "81724" {
            callbackError = BTCardError.cardAlreadyExists(validationError(with: error?.userInfo ?? [:]))
        } else {
            callbackError = BTCardError.customerInputInvalid(validationError(with: error?.userInfo ?? [:]))
        }

        return callbackError
    }
    
    // MARK: - Analytics Helper Methods
    
    private func notifySuccess(
        with result: BTCardNonce,
        completion: @escaping (BTCardNonce?, Error?) -> Void
    ) {
        apiClient.sendAnalyticsEvent(BTCardAnalytics.cardTokenizeSucceeded)
        completion(result, nil)
    }

    private func notifyFailure(with error: Error, completion: @escaping (BTCardNonce?, Error?) -> Void) {
        apiClient.sendAnalyticsEvent(BTCardAnalytics.cardTokenizeFailed, errorDescription: error.localizedDescription)
        completion(nil, error)
    }
}
