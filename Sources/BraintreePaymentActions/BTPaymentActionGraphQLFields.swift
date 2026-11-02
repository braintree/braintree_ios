import Foundation

/// The `paymentAction` selection set shared by every GraphQL operation that returns a
/// `PaymentAction` — `setPaymentActionPaymentMethod`, `getPaymentAction`, and
/// `signalCustomerActionComplete`. This is the schema-defined response shape, uniform regardless
/// of payment method, so it's safe to share rather than duplicate per operation.
///
/// `nextAction` only requests fields for the union members this SDK currently supports; others
/// (redirect, QR code, etc.) parse safely as `.unrecognized` until added.
enum BTPaymentActionGraphQLFields {

    // swiftlint:disable indentation_width
    static let paymentActionSelectionSet =
    """
     id
     status
     version
     nextAction {
      __typename
      ... on PaymentActionThreeDSecureAuthentication {
       bin
      }
      ... on PaymentActionThreeDSecureChallenge {
       acsUrl
       acsRenderingType
       challengePayload
       mpiTransactionId
      }
     }
    """
}
