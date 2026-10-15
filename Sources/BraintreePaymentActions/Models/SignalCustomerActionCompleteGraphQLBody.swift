import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The POST body for the GraphQL API `SignalCustomerActionComplete` mutation. Omits
/// `paymentActionId`, since the server resolves the Payment Action from the request's auth
/// fingerprint.
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
