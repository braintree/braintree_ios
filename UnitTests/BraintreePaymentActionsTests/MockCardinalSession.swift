import Foundation
import CardinalMobile
@testable import BraintreePaymentActions

/// Duplicated from `BraintreeThreeDSecureTests`' identical mock, scoped to this module's own
/// `CardinalSessionTestable` seam so `BraintreePaymentActionsTests` has no dependency on
/// `BraintreeThreeDSecure`.
///
/// `continueWith` calls `BTPaymentActionThreeDSecureProvider.resolveChallenge(actionCode:serverJWT:)`
/// directly rather than going through the `CardinalValidationDelegate` protocol method, since the real
/// `CardinalResponse` the protocol method requires has no accessible initializer and can't be
/// constructed from test code.
class MockCardinalSession: CardinalSessionTestable {

    var dfReferenceID = "fake-df-reference-id"

    /// When set, `continueWith` resolves the pending challenge continuation with this action code,
    /// simulating Cardinal's challenge completing. Left `nil`, `continueWith` does nothing (the
    /// continuation is left pending — used to exercise the watchdog).
    var actionCodeToDeliver: CardinalResponseActionCode?
    var serverJWTToDeliver = "fake-server-jwt"

    func configure(_ sessionConfig: CardinalSessionConfiguration) {
        // do nothing
    }

    func setup(
        jwtString: String,
        completed didCompleteHandler: @escaping CardinalSessionSetupDidCompleteHandler,
        validated didValidateHandler: @escaping CardinalSessionSetupDidValidateHandler
    ) {
        // `didValidateHandler` can't be invoked from a mock — its `CardinalResponse` parameter has no
        // accessible initializer (`NS_UNAVAILABLE`), so the setup-validation-failure path
        // (`BTPaymentActionError.cardinalSetupValidationFailed`) isn't exercisable from test code,
        // same limitation the Cardinal challenge spike found for `CardinalResponse` generally.
        didCompleteHandler(dfReferenceID)
    }

    func continueWith(transactionId: String, payload: String, validationDelegate: CardinalValidationDelegate) {
        guard let actionCodeToDeliver,
              let provider = validationDelegate as? BTPaymentActionThreeDSecureProvider else {
            return
        }
        provider.resolveChallenge(actionCode: actionCodeToDeliver, serverJWT: serverJWTToDeliver)
    }
}
