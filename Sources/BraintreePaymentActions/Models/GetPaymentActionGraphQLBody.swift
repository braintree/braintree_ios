import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The POST body for the GraphQL API `GetPaymentAction` query, which self-fetches the current
/// Payment Action using the request's auth fingerprint rather than an explicit `id`.
struct GetPaymentActionGraphQLBody: BTGraphQLEncodableBody {

    // swiftlint:disable indentation_width
    var query: String {
        """
        query GetPaymentAction {
         paymentAction {
        \(BTPaymentActionGraphQLFields.paymentActionSelectionSet)
         }
        }
        """
    }

    let variables = Variables()

    struct Variables: Encodable {}
}
