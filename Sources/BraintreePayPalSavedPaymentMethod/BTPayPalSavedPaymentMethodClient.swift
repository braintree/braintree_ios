import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
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

        guard apiClient.authorization.type == .clientToken else {
            throw BTPayPalSavedPaymentMethodError.invalidAuthorization
        }

        // The API rejects the request unless exactly the identity field matching the fetch type is sent.
        let parameters: PayPalFundingInstrumentDetailsGraphQLBody

        switch fundingInstrumentType {
        case .stickyFI:
            guard let jwt = (apiClient.authorization as? ClientTokenAuthorizationProviding)?.paymentMethodIDJWT else {
                throw BTPayPalSavedPaymentMethodError.missingPaymentMethodIDJWT
            }

            parameters = PayPalFundingInstrumentDetailsGraphQLBody(
                fundingInstrumentType: fundingInstrumentType,
                paymentMethodIDJWT: jwt,
                orderID: nil,
                merchantAccountID: merchantAccountID
            )
        case .fiFromApprovedCheckout:
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

        guard apiClient.authorization.type == .clientToken else {
            throw BTPayPalSavedPaymentMethodError.invalidAuthorization
        }

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
}
