import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreePayPal)
@_spi(BraintreePayPalSavedPaymentMethod) import BraintreePayPal
#endif

/// Fetches what to display for a buyer's vaulted PayPal payment method: the funding instrument PayPal will charge, and the
/// Pay Later message that accompanies it.
final class PayPalSavedPaymentMethodClient {

    // MARK: - Internal Properties

    /// Exposed for testing to get the instance of BTAPIClient
    var apiClient: BTAPIClient

    /// Exposed for testing to inject a mock BTPayPalClient
    var payPalClient: BTPayPalClient

    // MARK: - Initializer

    /// Creates a `PayPalSavedPaymentMethodClient`
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
    /// - Returns: A `PayPalSavedPaymentMethodSummary` describing what to display for the buyer
    /// - Throws: A `PayPalSavedPaymentMethodError` if the request cannot be built or the response cannot be parsed
    /// - Note: Requires a client token. Throws `PayPalSavedPaymentMethodError.invalidAuthorization` when initialized
    ///   with a tokenization key, which carries no `paymentMethodIdJwt`.
    func fetchPaymentMethod(
        fundingInstrumentType: PayPalFundingInstrumentFetchType,
        orderID: String? = nil,
        merchantAccountID: String? = nil
    ) async throws -> PayPalSavedPaymentMethodSummary {
        // The API rejects the request unless exactly the identity field matching the fetch type is sent.
        switch fundingInstrumentType {
        case .buyerDefaultBillingAgreement:
            return try await fetchBuyerDefaultBillingAgreement(merchantAccountID: merchantAccountID)
        case .buyerUpdatedBillingAgreement:
            return try await fetchBuyerUpdatedBillingAgreement(orderID: orderID, merchantAccountID: merchantAccountID)
        }
    }

    /// Fetches the PayPal Pay Later message to display alongside the funding instrument.
    /// - Parameters:
    ///   - amount: The order amount the message is calculated from, for example `"55.00"`.
    ///   - currencyCode: The ISO-4217 currency code for `amount`, for example `"USD"`.
    /// - Returns: A `PayPalCreditMessagingResult` describing the message to render
    /// - Throws: A `PayPalSavedPaymentMethodError` if the request cannot be built or PayPal returns no message
    /// - Note: The message is additive. Callers are expected to hide the row when this throws rather than fail checkout.
    /// - Note: Requires a client token. Throws `PayPalSavedPaymentMethodError.invalidAuthorization` when initialized
    ///   with a tokenization key, since the PayPal API rail authenticates with the client token's bearer.
    func fetchCreditPresentmentMessages(
        amount: String,
        currencyCode: String
    ) async throws -> PayPalCreditMessagingResult {
        try validateClientToken()

        apiClient.sendAnalyticsEvent(PayPalSavedPaymentMethodAnalytics.creditMessagingFetchStarted)
        do {
            let parameters = PayPalCreditMessagingPOSTBody(amount: amount, currencyCode: currencyCode)

            let (body, _) = try await apiClient.post(
                "/v2/credit/fetch-presentment-messages",
                parameters: parameters,
                httpType: .payPalAPI
            )

            guard let body else {
                throw PayPalSavedPaymentMethodError.emptyBodyReturned
            }

            guard let result = PayPalCreditMessagingResult(json: body) else {
                throw PayPalSavedPaymentMethodError.missingPreferredMessage
            }

            return result
        } catch {
            apiClient.sendAnalyticsEvent(
                PayPalSavedPaymentMethodAnalytics.creditMessagingFetchFailed,
                errorDescription: error.localizedDescription
            )
            throw error
        }
    }

    /// Tokenizes the edit of the buyer's funding instrument through the PayPal paysheet.
    /// - Parameter request: The checkout request to tokenize.
    /// - Returns: The tokenized `BTPayPalAccountNonce`. Its `paymentID` is the approved checkout order ID,
    ///   which callers pass to `fetchPaymentMethod(fundingInstrumentType: .buyerUpdatedBillingAgreement, orderID:)`.
    /// - Throws: `PayPalSavedPaymentMethodError.invalidAuthorization` or `.missingPaymentMethodIDJWT` before the paysheet
    ///   opens, since without the JWT PayPal would run a plain checkout instead of an edit.
    func editFundingInstrument(request: BTPayPalCheckoutRequest) async throws -> BTPayPalAccountNonce {
        _ = try paymentMethodIDJWT()

        return try await request.withEditBillingAgreement {
            try await payPalClient.tokenize(request)
        }
    }

    // MARK: - Private Methods

    private func fetchBuyerDefaultBillingAgreement(merchantAccountID: String?) async throws -> PayPalSavedPaymentMethodSummary {
        let paymentMethodIDJWT: String
        do {
            paymentMethodIDJWT = try self.paymentMethodIDJWT()
        } catch {
            let eventName = error as? PayPalSavedPaymentMethodError == .invalidAuthorization
                ? PayPalSavedPaymentMethodAnalytics.authorizationFailed
                : PayPalSavedPaymentMethodAnalytics.paymentMethodIDRequired
            apiClient.sendAnalyticsEvent(eventName, errorDescription: error.localizedDescription)
            throw error
        }

        apiClient.sendAnalyticsEvent(PayPalSavedPaymentMethodAnalytics.stickyFIFetchStarted)
        do {
            let summary = try await postFundingInstrumentDetails(
                PayPalFundingInstrumentDetailsGraphQLBody(
                    fundingInstrumentType: .buyerDefaultBillingAgreement,
                    paymentMethodIDJWT: paymentMethodIDJWT,
                    orderID: nil,
                    merchantAccountID: merchantAccountID
                )
            )
            apiClient.sendAnalyticsEvent(
                PayPalSavedPaymentMethodAnalytics.stickyFIFetchSucceeded,
                fiBrand: summary.paymentMethods.first?.cardBrand,
                fiID: summary.paymentMethods.first?.id,
                fiType: summary.paymentMethods.first?.type?.rawValue
            )
            return summary
        } catch {
            apiClient.sendAnalyticsEvent(
                PayPalSavedPaymentMethodAnalytics.stickyFIFetchFailed,
                errorDescription: error.localizedDescription
            )
            throw error
        }
    }

    private func fetchBuyerUpdatedBillingAgreement(
        orderID: String?,
        merchantAccountID: String?
    ) async throws -> PayPalSavedPaymentMethodSummary {
        apiClient.sendAnalyticsEvent(PayPalSavedPaymentMethodAnalytics.fiRefreshStarted, contextID: orderID)
        do {
            try validateClientToken()

            guard let orderID else {
                throw PayPalSavedPaymentMethodError.missingOrderID
            }

            let summary = try await postFundingInstrumentDetails(
                PayPalFundingInstrumentDetailsGraphQLBody(
                    fundingInstrumentType: .buyerUpdatedBillingAgreement,
                    paymentMethodIDJWT: nil,
                    orderID: orderID,
                    merchantAccountID: merchantAccountID
                )
            )
            apiClient.sendAnalyticsEvent(
                PayPalSavedPaymentMethodAnalytics.fiRefreshSucceeded,
                contextID: orderID,
                fiBrand: summary.paymentMethods.first?.cardBrand,
                fiID: summary.paymentMethods.first?.id,
                fiType: summary.paymentMethods.first?.type?.rawValue
            )
            return summary
        } catch {
            apiClient.sendAnalyticsEvent(
                PayPalSavedPaymentMethodAnalytics.fiRefreshFailed,
                contextID: orderID,
                errorDescription: error.localizedDescription
            )
            throw error
        }
    }

    private func postFundingInstrumentDetails(
        _ parameters: PayPalFundingInstrumentDetailsGraphQLBody
    ) async throws -> PayPalSavedPaymentMethodSummary {
        let (body, _) = try await apiClient.post("", parameters: parameters, httpType: .graphQLAPI)

        guard let body else {
            throw PayPalSavedPaymentMethodError.emptyBodyReturned
        }

        guard let summary = PayPalSavedPaymentMethodSummary(json: body["data"]["paypalFundingInstrumentDetails"]) else {
            throw PayPalSavedPaymentMethodError.failedToParseSummary
        }

        return summary
    }

    private func validateClientToken() throws {
        guard apiClient.authorization.type == .clientToken else {
            throw PayPalSavedPaymentMethodError.invalidAuthorization
        }
    }

    private func paymentMethodIDJWT() throws -> String {
        try validateClientToken()

        guard let jwt = (apiClient.authorization as? ClientTokenAuthorizationProviding)?.paymentMethodIDJWT else {
            throw PayPalSavedPaymentMethodError.missingPaymentMethodIDJWT
        }
        return jwt
    }
}
