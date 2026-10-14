import Foundation

/// The `paymentAction` selection set shared by every GraphQL operation that returns a
/// `PaymentAction` — `setPaymentActionPaymentMethod`, `getPaymentAction`, and
/// `signalCustomerActionComplete` — so the fields stay in sync across all three instead of being
/// duplicated per operation.
enum BTPaymentActionGraphQLFields {

    // swiftlint:disable indentation_width
    static let paymentActionSelectionSet =
    """
     id
     status
     nextAction {
      __typename
      ... on PaymentActionThreeDSecureAuthentication {
       bin
      }
      ... on PaymentActionThreeDSecureChallenge {
       acsUrl
       acsRenderingType
       challengePayload
      }
     }
    """
}
