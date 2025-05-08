/// The POST body for graph QL `query PaymentContext`
struct VenmoQueryPaymentContextGraphQLBody: Encodable {

    var query: String
    var variables: Variables

    init(paymentContextID: String?) {
        // swiftlint:disable:next line_length
        self.query = "query PaymentContext($id: ID!) { node(id: $id) { ... on VenmoPaymentContext { paymentMethodId userName payerInfo { firstName lastName phoneNumber email externalId userName shippingAddress { fullName addressLine1 addressLine2 adminArea1 adminArea2 postalCode countryCode } billingAddress { fullName addressLine1 addressLine2 adminArea1 adminArea2 postalCode countryCode } } } } }"
        self.variables = Variables(paymentContextID: paymentContextID)
    }

    struct Variables: Encodable {

        var paymentContextID: String?
    }
}
