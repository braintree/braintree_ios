import Foundation

/// The next action a Payment Action requires the client to complete, derived from the `nextAction`
/// union's `__typename` in the GraphQL response via `BTPaymentActionNextActionRegistry`.
enum BTNextAction: Equatable {

    /// Device data collection must be performed; the `bin` drives method selection (e.g. Cardinal setup).
    case threeDSecureAuthentication(BTPaymentActionThreeDSecureAuthenticationNextAction)

    /// A 3D Secure challenge must be presented to the customer.
    case threeDSecureChallenge(BTPaymentActionThreeDSecureChallengeNextAction)

    /// A `nextAction` whose `__typename` was not recognized by this SDK version.
    case unrecognized(typeName: String?)
}

/// The `PaymentActionThreeDSecureAuthentication` next-action payload: triggers device data collection.
struct BTPaymentActionThreeDSecureAuthenticationNextAction: Equatable {

    let bin: String
}

/// The `PaymentActionThreeDSecureChallenge` next-action payload: triggers the Cardinal challenge UI.
struct BTPaymentActionThreeDSecureChallengeNextAction: Equatable {

    let acsURL: URL
    let acsRenderingType: String?
    let challengePayload: String

    /// Cardinal's transaction id for this challenge, passed to `continueWith(transactionId:payload:...)`.
    /// Confirmed nullable on the wire (Payment Actions backend team, 2026-10).
    let mpiTransactionID: String?
}
