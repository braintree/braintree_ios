import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The POST body for the GraphQL API `GetPaymentAction` self-fetch query.
///
/// The Payment Action is resolved from the request's auth fingerprint — the query takes no explicit
/// `id` argument, matching how `BTPaymentActionsClient` is scoped to a single Payment Action per
/// instance's authorization.
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
