import Foundation

/// Mirrors the GraphQL `CustomerActionCompleteInput` `@oneOf` input on `signalCustomerActionComplete` —
/// exactly one case is ever encoded, enforced by the type system rather than by convention.
enum BTCustomerCompletedAction: Encodable, Equatable {

    /// Signals that device data collection (the 3D Secure authentication step) has completed.
    case deviceDataCollection(dfReferenceID: String)

    /// Signals that the 3D Secure challenge has completed.
    case challenge(cardinalAuthenticationJWT: String)

    // MARK: - Encodable

    private enum CodingKeys: String, CodingKey {
        case deviceDataCollection
        case challenge
    }

    private enum DeviceDataCollectionCodingKeys: String, CodingKey {
        case dfReferenceID
    }

    private enum ChallengeCodingKeys: String, CodingKey {
        case cardinalAuthenticationJWT
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .deviceDataCollection(let dfReferenceID):
            var nested = container.nestedContainer(
                keyedBy: DeviceDataCollectionCodingKeys.self,
                forKey: .deviceDataCollection
            )
            try nested.encode(dfReferenceId, forKey: .dfReferenceId)
        case .challenge(let cardinalAuthenticationJWT):
            var nested = container.nestedContainer(keyedBy: ChallengeCodingKeys.self, forKey: .challenge)
            try nested.encode(cardinalAuthenticationJWT, forKey: .cardinalAuthenticationJWT)
        }
    }
}
