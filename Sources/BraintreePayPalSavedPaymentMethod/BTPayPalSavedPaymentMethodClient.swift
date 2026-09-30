import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreePayPal)
@_spi(BraintreePayPalSavedPaymentMethod) import BraintreePayPal
#endif

/// Fetches what to display for a buyer's vaulted PayPal payment method: the funding instrument PayPal will charge, and the
/// Pay Later message that accompanies it.
final class BTPayPalSavedPaymentMethodClient {

    // MARK: - Internal Properties

    /// Exposed for testing to get the instance of BTAPIClient
    var apiClient: BTAPIClient

    /// Exposed for testing to inject a mock BTPayPalClient
    var payPalClient: BTPayPalClient

    // MARK: - Initializer

    /// Creates a `BTPayPalSavedPaymentMethodClient`
    /// - Parameters:
    ///   - authorization: A client token generated with the buyer's payment method ID. A tokenization key
    ///     cannot be used — it carries no `paymentMethodIdJwt`, so the saved funding instrument cannot be resolved.
    ///   - universalLink: The URL used for the PayPal app switch flow.
    ///   - fallbackURLScheme: A custom URL scheme used if the universal link fails.
    init(authorization: String, universalLink: URL, fallbackURLScheme: String? = nil) {
        self.apiClient = BTAPIClient(authorization: authorization)
        self.payPalClient = BTPayPalClient(
            authorization: authorization,
            universalLink: universalLink,
            fallbackURLScheme: fallbackURLScheme
        )
    }

    // MARK: - Internal Methods

    /// Fetches the funding instrument details for a vaulted PayPal payment method.
    /// - Parameters:
    ///   - fundingInstrumentType: Which funding instrument to resolve. `buyerDefaultBillingAgreement` uses the payment
    ///     method ID JWT carried by the client token; `buyerUpdatedBillingAgreement` requires `orderID`.
    ///   - orderID: The approved checkout order ID. Required for `buyerUpdatedBillingAgreement` and ignored otherwise.
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
        // TODO: emit the default and updated billing agreement analytics events once the catalog is approved.

        try validateClientToken()

        // The API rejects the request unless exactly the identity field matching the fetch type is sent.
        let parameters: PayPalFundingInstrumentDetailsGraphQLBody

        switch fundingInstrumentType {
        case .buyerDefaultBillingAgreement:
            parameters = PayPalFundingInstrumentDetailsGraphQLBody(
                fundingInstrumentType: fundingInstrumentType,
                paymentMethodIDJWT: try paymentMethodIDJWT(),
                orderID: nil,
                merchantAccountID: merchantAccountID
            )
        case .buyerUpdatedBillingAgreement:
            guard let orderID else {
                throw BTPayPalSavedPaymentMethodError.missingOrderID
            }

            parameters = PayPalFundingInstrumentDetailsGraphQLBody(
                fundingInstrumentType: fundingInstrumentType,
                paymentMethodIDJWT: nil,
                orderID: orderID,
                merchantAccountID: merchantAccountID
            )
        }

        let (body, _) = try await apiClient.post("", parameters: parameters, httpType: .graphQLAPI)

        guard let body else {
            throw BTPayPalSavedPaymentMethodError.emptyBodyReturned
        }

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

        try validateClientToken()

        let parameters = PayPalCreditMessagingPOSTBody(amount: amount, currencyCode: currencyCode)

        let (body, _) = try await apiClient.post(
            "/v2/credit/fetch-presentment-messages",
            parameters: parameters,
            httpType: .payPalAPI
        )

        guard let body else {
            throw BTPayPalSavedPaymentMethodError.emptyBodyReturned
        }

        guard let result = BTPayPalCreditMessagingResult(json: body) else {
            throw BTPayPalSavedPaymentMethodError.missingPreferredMessage
        }

        return result
    }

    /// Tokenizes the edit of the buyer's funding instrument through the PayPal paysheet.
    /// - Parameter request: The checkout request to tokenize.
    /// - Returns: The tokenized `BTPayPalAccountNonce`. Its `paymentID` is the approved checkout order ID,
    ///   which callers pass to `fetchPaymentMethod(fundingInstrumentType: .buyerUpdatedBillingAgreement, orderID:)`.
    /// - Throws: `BTPayPalSavedPaymentMethodError.invalidAuthorization` or `.missingPaymentMethodIDJWT` before the paysheet
    ///   opens, since without the JWT PayPal would run a plain checkout instead of an edit.
    func editFundingInstrument(request: BTPayPalCheckoutRequest) async throws -> BTPayPalAccountNonce {
        _ = try paymentMethodIDJWT()

        return try await request.withEditBillingAgreement {
            try await payPalClient.tokenize(request)
        }
    }

    // MARK: - Private Methods

    private func validateClientToken() throws {
        guard apiClient.authorization.type == .clientToken else {
            throw BTPayPalSavedPaymentMethodError.invalidAuthorization
        }
    }

    private func paymentMethodIDJWT() throws -> String {
        try validateClientToken()

        guard let jwt = (apiClient.authorization as? ClientTokenAuthorizationProviding)?.paymentMethodIDJWT else {
            throw BTPayPalSavedPaymentMethodError.missingPaymentMethodIDJWT
        }

        return jwt
    }
}
