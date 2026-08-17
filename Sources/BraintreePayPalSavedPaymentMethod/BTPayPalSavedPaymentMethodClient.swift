import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreePayPal)
import BraintreePayPal
#endif

/// Fetches what to display for a buyer's vaulted PayPal payment method: the funding instrument PayPal will charge, and the
/// Pay Later message that accompanies it.
final class BTPayPalSavedPaymentMethodClient {

    // MARK: - Internal Properties

    /// Exposed for testing to get the instance of BTAPIClient
    var apiClient: BTAPIClient

    // MARK: - Initializer

    /// Creates a `BTPayPalSavedPaymentMethodClient`
    /// - Parameter authorization: A client token generated with the buyer's payment method ID. A tokenization key
    ///   cannot be used — it carries no `paymentMethodIdJwt`, so the saved funding instrument cannot be resolved.
    init(authorization: String) {
        self.apiClient = BTAPIClient(authorization: authorization)
    }

    // MARK: - Internal Methods

    /// Fetches the funding instrument details for a vaulted PayPal payment method.
    /// - Parameters:
    ///   - fundingInstrumentType: Which funding instrument to resolve. `stickyFI` uses the payment method ID JWT carried by the
    ///     client token; `fiFromApprovedCheckout` requires `orderID`.
    ///   - orderID: The approved checkout order ID. Required for `fiFromApprovedCheckout` and ignored otherwise.
    ///   - merchantAccountID: Optional. A non-default merchant account to resolve the funding instrument against. Applies to
    ///     both fetch types and is omitted from the request when nil, so the default merchant account is used.
    /// - Returns: A `BTPayPalSavedPaymentMethodSummary` describing what to display for the buyer
    /// - Throws: A `BTPayPalSavedPaymentMethodError` if the request cannot be built or the response cannot be parsed
    /// - Note: Requires a client token. Throws `BTPayPalSavedPaymentMethodError.invalidAuthorization` when initialized
    ///   with a tokenization key, which carries no `paymentMethodIdJwt`.
    func fetchPaymentMethod(
        fundingInstrumentType: BTPayPalFundingInstrumentFetchType,
        orderID: String? = nil,
        merchantAccountID: String? = nil
    ) async throws -> BTPayPalSavedPaymentMethodSummary {
        // TODO: emit the sticky-FI and post-edit refresh analytics events once the catalog is approved.

        try validateClientTokenAuthorization()

        // The API rejects the request unless exactly the identity field matching the fetch type is sent.
        let paymentMethodIDJWT: String?
        let resolvedOrderID: String?

        switch fundingInstrumentType {
        case .stickyFI:
            guard let jwt = (apiClient.authorization as? ClientTokenAuthorizationProviding)?.paymentMethodIDJWT else {
                throw BTPayPalSavedPaymentMethodError.missingPaymentMethodIDJWT
            }

            paymentMethodIDJWT = jwt
            resolvedOrderID = nil
        case .fiFromApprovedCheckout:
            guard let orderID else {
                throw BTPayPalSavedPaymentMethodError.missingOrderID
            }

            paymentMethodIDJWT = nil
            resolvedOrderID = orderID
        }

        let parameters = PayPalFundingInstrumentDetailsGraphQLBody(
            fundingInstrumentType: fundingInstrumentType,
            paymentMethodIDJWT: paymentMethodIDJWT,
            orderID: resolvedOrderID,
            merchantAccountID: merchantAccountID
        )

        let body = try await post("", parameters: parameters, httpType: .graphQLAPI)

        guard let summary = BTPayPalSavedPaymentMethodSummary(json: body["data"]["paypalFundingInstrumentDetails"]) else {
            throw BTPayPalSavedPaymentMethodError.failedToParseSummary
        }

        return summary
    }

    /// Fetches the PayPal Pay Later message to display alongside the funding instrument.
    /// - Parameters:
    ///   - amount: The order amount the message is calculated from, for example `"55.00"`.
    ///   - currencyCode: The ISO-4217 currency code for `amount`, for example `"USD"`.
    /// - Returns: A `BTPayPalCreditMessagingResult` describing the message to render
    /// - Throws: A `BTPayPalSavedPaymentMethodError` if the request cannot be built or PayPal returns no message
    /// - Note: The message is additive. Callers are expected to hide the row when this throws rather than fail checkout.
    /// - Note: Requires a client token. Throws `BTPayPalSavedPaymentMethodError.invalidAuthorization` when initialized
    ///   with a tokenization key, since the PayPal API rail authenticates with the client token's bearer.
    func fetchCreditPresentmentMessages(
        amount: String,
        currencyCode: String
    ) async throws -> BTPayPalCreditMessagingResult {
        // TODO: emit the credit messaging analytics events once the catalog is approved.

        try validateClientTokenAuthorization()

        let parameters = PayPalCreditMessagingPOSTBody(amount: amount, currencyCode: currencyCode)

        let body = try await post(
            "/v2/credit/fetch-presentment-messages",
            parameters: parameters,
            httpType: .payPalAPI
        )

        guard let result = BTPayPalCreditMessagingResult(json: body) else {
            throw BTPayPalSavedPaymentMethodError.missingPreferredMessage
        }

        return result
    }

    /// Edits the buyer's funding instrument, then refreshes what to display for the approved checkout.
    /// - Parameters:
    ///   - request: The checkout request to tokenize (carries `editBillingAgreement`).
    ///   - merchantAccountID: The merchant account the refreshed funding instrument is fetched against.
    /// - Returns: The tokenized `nonce`, the refreshed `summary` (or `nil`), and a cosmetic `refreshError`.
    /// - Note: Placeholder — the real tokenize (PayPal paysheet) + `fiFromApprovedCheckout` refresh is
    ///   delivered by the data layer in a follow-up. This stub lets the UI integration build and wire
    ///   against the final signature.
    func editFundingInstrument(
        request: BTPayPalCheckoutRequest,
        merchantAccountID: String? = nil
    ) async throws -> (nonce: BTPayPalAccountNonce, summary: BTPayPalSavedPaymentMethodSummary?, refreshError: Error?) {
        throw NSError(
            domain: BTPayPalSavedPaymentMethodError.errorDomain,
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "editFundingInstrument is not yet implemented."]
        )

    // MARK: - Private Methods

    /// The GraphQL rail reads the client token's `paymentMethodIdJwt` and the PayPal API rail authenticates with its bearer,
    /// so neither works with a tokenization key.
    private func validateClientTokenAuthorization() throws {
        guard apiClient.authorization.type == .clientToken else {
            throw BTPayPalSavedPaymentMethodError.invalidAuthorization
        }
    }

    private func post(
        _ path: String,
        parameters: Encodable,
        httpType: BTAPIClientHTTPService
    ) async throws -> BTJSON {
        let (body, _) = try await apiClient.post(path, parameters: parameters, httpType: httpType)

        guard let body else {
            throw BTPayPalSavedPaymentMethodError.emptyBodyReturned
        }

        return body
    }
}
