import Foundation

/// Represents the different shapes `nextAction` can take when returned from a Payment Action GraphQL mutation
/// relating to a 3DS flow.
@_documentation(visibility: private)
enum BTNextAction {
    
    case provideCVV
    case redirect(url: String)
    // swiftlint:disable:next enum_case_associated_values_count
    case threeDSecure(
        songbirdURL: String?,
        cardinalAuthenticationJWT: String?,
        bin: String?,
        acsURL: String?,
        challengePayload: String?
    )
    case unknown
}
