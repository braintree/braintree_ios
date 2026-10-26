import Foundation

///  Error details associated with Payment Actions.
public enum BTPaymentActionError: Error, CustomNSError, LocalizedError, Equatable {
    
    /// 0. Response is missing a Payment Action id
    case missingID
    
    /// 1. Response is missing a Payment Action status
    case missingStatus
    
    /// 2. Failed to decode the Payment Action response
    case decodingFailure
    
    /// 3. The `BTPaymentActionRequest` subclass did not override `paymentMethodParameters()`
    case missingParameters

    /// 4. `handleNextAction` was called while a previous invocation on this client was still in flight
    case handleNextActionAlreadyInProgress

    /// 5. A Payment Action's `version` decreased between two fetches within a single `handleNextAction`
    /// drive loop, which should never happen and indicates a stale or out-of-order response.
    case versionAnomaly

    /// 6. Deallocated BTPaymentActionsClient
    case deallocated

    /// 7. The Payment Actions configuration is missing the Cardinal authentication JWT needed to
    /// configure a 3D Secure session.
    case missingCardinalAuthenticationJWT

    /// 8. A 3D Secure device data collection or challenge step was attempted while the app was not
    /// in the foreground — Cardinal requires a foregrounded app to present its UI.
    case foregroundRequired

    /// 9. A 3D Secure challenge did not resolve within the SDK's own bounded watchdog window.
    case cardinalChallengeTimedOut

    /// 10. CardinalMobile reported a validation failure (`.error`) during the 3D Secure challenge.
    case cardinalChallengeFailed

    /// 11. CardinalMobile returned an action code this SDK version does not recognize.
    case unrecognizedCardinalActionCode

    /// 12. CardinalMobile failed to validate the Cardinal authentication JWT during session setup.
    case cardinalSetupValidationFailed

    /// 13. A 3D Secure device data collection or challenge step was requested while a previous one on
    /// the same provider instance was still in flight.
    case cardinalInteractionAlreadyInProgress

    public static var errorDomain: String {
        "com.braintreepayments.BTPaymentActionErrorDomain"
    }
    
    public var errorCode: Int {
        switch self {
        case .missingID:
            return 0
        case .missingStatus:
            return 1
        case .decodingFailure:
            return 2
        case .missingParameters:
            return 3
        case .handleNextActionAlreadyInProgress:
            return 4
        case .versionAnomaly:
            return 5
        case .deallocated:
            return 6
        case .missingCardinalAuthenticationJWT:
            return 7
        case .foregroundRequired:
            return 8
        case .cardinalChallengeTimedOut:
            return 9
        case .cardinalChallengeFailed:
            return 10
        case .unrecognizedCardinalActionCode:
            return 11
        case .cardinalSetupValidationFailed:
            return 12
        case .cardinalInteractionAlreadyInProgress:
            return 13
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .missingID:
            return "Payment Action response is missing an id."
        case .missingStatus:
            return "Payment Action response is missing a status."
        case .decodingFailure:
            return "Failed to decode Payment Action response."
        case .missingParameters:
            return "BTPaymentActionRequest subclass did not override paymentMethodParameters()."
        case .handleNextActionAlreadyInProgress:
            return "handleNextAction was called while a previous invocation on this client was still in flight."
        case .versionAnomaly:
            return "Payment Action version decreased between fetches during handleNextAction."
        case .deallocated:
            return "BTPaymentActionsClient has been deallocated."
        case .missingCardinalAuthenticationJWT:
            return "Payment Actions configuration is missing the Cardinal authentication JWT."
        case .foregroundRequired:
            return "A 3D Secure device data collection or challenge step requires the app to be in the foreground."
        case .cardinalChallengeTimedOut:
            return "The 3D Secure challenge did not resolve within the expected time."
        case .cardinalChallengeFailed:
            return "CardinalMobile reported a validation failure during the 3D Secure challenge."
        case .unrecognizedCardinalActionCode:
            return "CardinalMobile returned an action code this SDK version does not recognize."
        case .cardinalSetupValidationFailed:
            return "CardinalMobile failed to validate the Cardinal authentication JWT during session setup."
        case .cardinalInteractionAlreadyInProgress:
            return "A 3D Secure step was requested while a previous one was still in flight."
        }
    }
    
    // MARK: - Equatable Conformance
    
    public static func == (lhs: BTPaymentActionError, rhs: BTPaymentActionError) -> Bool {
        lhs.errorCode == rhs.errorCode
    }
}
