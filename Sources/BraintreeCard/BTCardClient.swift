import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Used to process cards
@objc public class BTCardClient_Swift: NSObject {

    // MARK: - Internal Properties

    /// Exposed for testing to get the instance of BTAPIClient
    let apiClient: BTAPIClient

    let graphQLTokenizeFeature: String = "tokenize_credit_cards"

    // MARK: - Initializer

    /// Creates a card client
    /// - Parameter apiClient: An API client
    @objc(initWithAPIClient:)
    init(apiClient: BTAPIClient) {
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

    }

    // TODO: add async/await method

    // MARK: - Internal Methods

    /// Convenience helper method for creating friendlier, more human-readable userInfo dictionaries for 422 HTTP errors
    func validationErrorUserInfo(_ userInfo: [String: Any]) -> [String: Any] {
        return [:]
    }

    // TODO: see if we can use error instead?
    func constructCallbackErrorForErrorUserInfo(errorUserInfo: [String: Any], error: NSError) -> Error {
        var errorResponse: BTJSON? = error.userInfo[BTCoreConstants.jsonResponseBodyKey] as? BTJSON
        var fieldErrors: BTJSON? = errorResponse?["fieldErrors"].asArray()?.first
        var errorCode: BTJSON? = fieldErrors?["fieldErrors"].asArray()?.first?["code"]

        var callbackError: Error = error
        if errorCode != nil {
            let errorResponse: BTJSON? = errorUserInfo[BTCoreConstants.jsonResponseBodyKey] as? BTJSON
            errorCode = errorResponse?["errors"].asArray()?.first?["extensions"]["legacyCode"]
        }

        // Gateway error code for card already exists
        if errorCode?.asString() == "81724" {
            callbackError = BTCardError.cardAlreadyExists(validationErrorUserInfo(error.userInfo))
        } else {
            callbackError = BTCardError.customerInputInvalid(validationErrorUserInfo(error.userInfo))
        }

        return callbackError
    }
}
