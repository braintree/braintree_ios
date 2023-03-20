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
        let request = BTCardRequest(card: card)

        apiClient.fetchOrReturnRemoteConfiguration() { configuration, error in
            guard let configuration, error != nil else {
                completion(nil, error)
                return
            }

            if self.isGraphQLEnabled(for: configuration) {
                if request.card.authenticationInsightRequested && request.card.merchantAccountID == nil {
                    completion(nil, BTCardError.integration)
                    return
                }

                let parameters = request.card.graphQLParameters()

                self.apiClient.post("", parameters: parameters, httpType: .graphQLAPI) { body, _, error in
                    if let error = error as NSError? {
                        if error.code == BTCoreConstants.networkConnectionLostCode {
                            self.apiClient.sendAnalyticsEvent("ios.tokenize-card.graphQL.network-connection.failure")
                        }

                        let response: HTTPURLResponse? = error.userInfo[BTCoreConstants.urlResponseKey] as? HTTPURLResponse
                        var callbackError: Error? = error

                        if response?.statusCode == 422 {
                            callbackError = self.constructCallbackError(for: error.userInfo, error: error)
                        }

                        self.sendGraphQLAnalyticsEvent(with: false)
                        completion(nil, callbackError)
                        return
                    }

                    let cardJSON: BTJSON = body?["data"]["tokenizeCreditCard"] ?? BTJSON()
                    self.sendGraphQLAnalyticsEvent(with: true)

                    let cardNonce: BTCardNonce = BTCardNonce(graphQLJSON: cardJSON)
                    completion(cardNonce, cardJSON.asError())
                    return
                }
            } else {
                let parameters = self.clientAPIParameters(for: request)

                self.apiClient.post("v1/payment_methods/credit_cards", parameters: parameters) {body, _, error in
                    if let error = error as NSError? {
                        if error.code == BTCoreConstants.networkConnectionLostCode {
                            self.apiClient.sendAnalyticsEvent("ios.tokenize-card.network-connection.failure")
                        }

                        let response: HTTPURLResponse? = error.userInfo[BTCoreConstants.urlResponseKey] as? HTTPURLResponse
                        var callbackError: Error? = error

                        if response?.statusCode == 422 {
                            callbackError = self.constructCallbackError(for: error.userInfo, error: error)
                        }

                        self.sendAnalyticsEvent(with: false)
                        completion(nil, callbackError)
                        return
                    }

                    let cardJSON: BTJSON = body?["creditCards"][0] ?? BTJSON()
                    self.sendAnalyticsEvent(with: !cardJSON.isError)

                    // cardNonceWithJSON returns nil when cardJSON is nil, cardJSON.asError is nil when cardJSON is non-nil
                    let cardNonce: BTCardNonce = BTCardNonce(json: cardJSON)
                    completion(cardNonce, cardJSON.asError())
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

    // MARK: - Internal Methods

    func isGraphQLEnabled(for configuration: BTConfiguration) -> Bool {
        if let graphQLFeatures = configuration.json?["graphQL"]["features"].asStringArray() {
            return !graphQLFeatures.isEmpty && graphQLFeatures.contains(graphQLTokenizeFeature)
        }

        return false
    }

    // MARK: - Analytics

    func sendAnalyticsEvent(with success: Bool) {
        let integration = apiClient.metadata.integrationString
        let status = success ? "succeeded" : "failed"
        let event = "ios.\(integration).card.\(status)"

        apiClient.sendAnalyticsEvent(event)
    }

    func sendGraphQLAnalyticsEvent(with success: Bool) {
        let status = success ? "success" : "failure"
        let event = "ios.card.graphql.tokenization.\(status)"

        apiClient.sendAnalyticsEvent(event)
    }

    // MARK: - Error Construction Methods

    /// Convenience helper method for creating friendlier, more human-readable userInfo dictionaries for 422 HTTP errors
    func validationError(with userInfo: [String: Any]) -> [String: Any] {
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

    func clientAPIParameters(for request: BTCardRequest) -> [String: Any] {
        var parameters: [String: Any] = [:]
        parameters["credit_card"] = request.card.parameters()

        let metadata: [String: String] = [
            "source": apiClient.metadata.sourceString,
            "integration": apiClient.metadata.integrationString,
            "sessionId": apiClient.metadata.sessionID
        ]

        parameters["_meta"] = metadata

        if request.card.authenticationInsightRequested {
            parameters["authenticationInsight"] = true
            parameters["merchantAccountId"] = request.card.merchantAccountID
        }

        return parameters
    }

    // TODO: see if we can use error instead?
    func constructCallbackError(for errorUserInfo: [String: Any], error: NSError?) -> Error? {
        let errorResponse: BTJSON? = error?.userInfo[BTCoreConstants.jsonResponseBodyKey] as? BTJSON
        let fieldErrors: BTJSON? = errorResponse?["fieldErrors"].asArray()?.first

        var errorCode: BTJSON? = fieldErrors?["fieldErrors"].asArray()?.first?["code"]
        var callbackError: Error? = error

        if errorCode != nil {
            let errorResponse: BTJSON? = errorUserInfo[BTCoreConstants.jsonResponseBodyKey] as? BTJSON
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
}
