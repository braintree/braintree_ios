import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Fetches the funding instrument that PayPal will charge for a buyer's vaulted PayPal payment method.
final class BTPayPalSavedPaymentMethodClient {

    // MARK: - Internal Properties

    /// Exposed for testing to get the instance of BTAPIClient
    var apiClient: BTAPIClient

    // MARK: - Initializer

    /// Creates a `BTPayPalSavedPaymentMethodClient`
    /// - Parameter authorization: A client token generated with the buyer's payment method ID
    init(authorization: String) {
        self.apiClient = BTAPIClient(authorization: authorization)
    }

    // MARK: - Internal Methods

    /// Fetches the funding instrument details for a vaulted PayPal payment method.
    /// - Parameters:
    ///   - fundingInstrumentType: Which funding instrument to resolve. `stickyFI` uses the payment method ID JWT carried by the
    ///     client token; `fiFromApprovedCheckout` requires `orderID`.
    ///   - orderID: The approved checkout order ID. Required for `fiFromApprovedCheckout` and ignored otherwise.
    ///   - merchantAccountID: The merchant account the funding instrument is fetched against.
    /// - Returns: A `BTPayPalSavedPaymentMethodSummary` describing what to display for the buyer
    /// - Throws: A `BTPayPalSavedPaymentMethodError` if the request cannot be built or the response cannot be parsed
    func fetchPaymentMethod(
        fundingInstrumentType: BTPayPalFundingInstrumentFetchType,
        orderID: String? = nil,
        merchantAccountID: String? = nil
    ) async throws -> BTPayPalSavedPaymentMethodSummary {
        guard apiClient.authorization.type == .clientToken else {
            throw BTPayPalSavedPaymentMethodError.invalidAuthorization
        }

        // The API rejects the request unless exactly the identity field matching the fetch type is sent.
        let paymentMethodIDJWT: String?
        let resolvedOrderID: String?

        switch fundingInstrumentType {
        case .stickyFI:
            guard let jwt = apiClient.authorization.paymentMethodIDJWT else {
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

        let (body, _) = try await apiClient.post("", parameters: parameters, httpType: .graphQLAPI)

        guard let body else {
            throw BTPayPalSavedPaymentMethodError.emptyBodyReturned
        }

        guard let summary = BTPayPalSavedPaymentMethodSummary(json: body["data"]["paypalFundingInstrumentDetails"]) else {
            throw BTPayPalSavedPaymentMethodError.failedToParseSummary
        }

        return summary
    }
}
