import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The POST body for the GraphQL API `SignalCustomerActionComplete` mutation.
///
/// `paymentActionId` is intentionally omitted — the client always calls this under a payment-action-scoped
/// auth fingerprint, which the server uses to resolve the Payment Action without an explicit id.
struct SignalCustomerActionCompleteGraphQLBody: BTGraphQLEncodableBody {

    // swiftlint:disable indentation_width
    var query: String {
        """
        mutation SignalCustomerActionComplete($input: SignalCustomerActionCompleteInput!) {
         signalCustomerActionComplete(input: $input) {
          paymentAction {
        \(BTPaymentActionGraphQLFields.paymentActionSelectionSet)
          }
         }
        }
        """
    }

    let variables: Variables

    init(completedAction: BTCustomerCompletedAction) {
        self.variables = Variables(input: Input(customerActionComplete: completedAction))
    }

    struct Variables: Encodable {

        let input: Input
    }

    struct Input: Encodable {

        let customerActionComplete: BTCustomerCompletedAction
    }
}
