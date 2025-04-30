import Foundation

/// The POST body for GraphQL API Venmo POST
struct VenmoGraphQLBody: Encodable {

    var query: String
    var variables: Variables

    init(paymentContextID: String?) {
        self.query = "query PaymentContext($id: ID!) { node(id: $id) { ... on VenmoPaymentContext { paymentMethodId userName payerInfo { firstName lastName phoneNumber email externalId userName shippingAddress { fullName addressLine1 addressLine2 adminArea1 adminArea2 postalCode countryCode } billingAddress { fullName addressLine1 addressLine2 adminArea1 adminArea2 postalCode countryCode } } } } }"
        self.variables = Variables(paymentContextID: paymentContextID)
    }

    struct Variables: Encodable {
        
        var paymentContextID: String?
    }
}
