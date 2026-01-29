import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Used to process cards
@objc public class BTCardClient: NSObject {

    // MARK: - Internal Properties

    /// Exposed for testing to get the instance of BTAPIClient
    var apiClient: BTAPIClient

    let graphQLTokenizeFeature: String = "tokenize_credit_cards"

    // MARK: - Initializer

    /// Creates a card client
    /// - Parameter authorization: A valid client token or tokenization key used to authorize API calls.
    @objc(initWithAuthorization:)
    public init(authorization: String) {
        self.apiClient = BTAPIClient(authorization: authorization)
    }

    // MARK: - Public Methods

    /// Tokenizes a card
    /// - Parameters:
    ///    - card: The card to tokenize.
    ///    - completion: A completion block that is invoked when card tokenization has completed. If tokenization succeeds,
    ///    `tokenize` will contain a nonce and `error` will be `nil`; if it fails, `tokenize` will be `nil` and `error`will describe the failure.
    @objc(tokenizeCard:completion:)
    public func tokenize(_ card: BTCard, completion: @escaping (BTCardNonce?, Error?) -> Void) {
        Task { @MainActor in
            do {
                let cardNonce = try await tokenize(card)
                completion(cardNonce, nil)
            } catch {
                completion(nil, error)
            }
        }
    }

    /// Tokenizes a card
    /// - Parameter card: The card to tokenize.
    /// - Returns: On success, you will receive an instance of `BTCardNonce`
    /// - Throws: An `Error` describing the failure
    public func tokenize(_ card: BTCard) async throws -> BTCardNonce {
        apiClient.sendAnalyticsEvent(BTCardAnalytics.cardTokenizeStarted)

        do {
            let configuration = try await apiClient.fetchOrReturnRemoteConfiguration()

            if isGraphQLEnabled(for: configuration) {
                if card.authenticationInsightRequested && card.merchantAccountID == nil {
                    throw BTCardError.integration
                }

                let parameters = card.graphQLParameters()

                do {
                    let (body, _) = try await apiClient.post("", parameters: parameters, httpType: .graphQLAPI)

                    let cardJSON: BTJSON = body?["data"]["tokenizeCreditCard"] ?? BTJSON()

                    if let cardJSONError = cardJSON.asError() {
                        notifyFailure(with: cardJSONError)
                        throw cardJSONError
                    }

                    let cardNonce = BTCardNonce(graphQLJSON: cardJSON)
                    notifySuccess()
                    return cardNonce
                } catch {
                    let nsError = error as NSError
                    let response: HTTPURLResponse? = nsError.userInfo[BTCoreConstants.urlResponseKey] as? HTTPURLResponse
                    var callbackError: Error = error

                    if response?.statusCode == 422 {
                        callbackError = constructCallbackError(with: nsError.userInfo, error: nsError) ?? error
                    }

                    notifyFailure(with: callbackError)
                    throw callbackError
                }
            } else {
                let parameters = card.parameters(apiClient: apiClient)

                do {
                    let (body, _) = try await apiClient.post("v1/payment_methods/credit_cards", parameters: parameters)

                    let cardJSON: BTJSON = body?["creditCards"][0] ?? BTJSON()

                    if let cardJSONError = cardJSON.asError() {
                        notifyFailure(with: cardJSONError)
                        throw cardJSONError
                    }

                    let cardNonce = BTCardNonce(json: cardJSON)
                    notifySuccess()
                    return cardNonce
                } catch {
                    let nsError = error as NSError
                    let response: HTTPURLResponse? = nsError.userInfo[BTCoreConstants.urlResponseKey] as? HTTPURLResponse
                    var callbackError: Error = error

                    if response?.statusCode == 422 {
                        callbackError = constructCallbackError(with: nsError.userInfo, error: nsError) ?? error
                    }

                    notifyFailure(with: callbackError)
                    throw callbackError
                }
            }
        } catch {
            notifyFailure(with: error)
            throw error
        }
    }

    // MARK: - Private Methods

    private func isGraphQLEnabled(for configuration: BTConfiguration) -> Bool {
        if let graphQLFeatures = configuration.json?["graphQL"]["features"].asStringArray() {
            return !graphQLFeatures.isEmpty && graphQLFeatures.contains(graphQLTokenizeFeature)
        }

        return false
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

    private func notifySuccess() {
        apiClient.sendAnalyticsEvent(BTCardAnalytics.cardTokenizeSucceeded)
    }

    private func notifyFailure(with error: Error) {
        apiClient.sendAnalyticsEvent(BTCardAnalytics.cardTokenizeFailed, errorDescription: error.localizedDescription)
    }
}
