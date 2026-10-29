import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Resolves a `nextAction` union JSON payload into a `BTNextAction` by its `__typename`,
/// so callers never have to branch on a raw type string.
///
/// Each `nextAction` union member registers a parsing closure keyed on the GraphQL `__typename` i
/// resolves. An unrecognized `__typename` — a union member this SDK version doesn't know about yet —
/// resolves to `.unrecognized` rather than failing the response, since the schema is additive and new
/// action types (redirect, QR code, CVV input, etc.) may be returned before this SDK supports them.
final class BTPaymentActionNextActionRegistry {

    // MARK: - Internal Static Properties

    static let shared = BTPaymentActionNextActionRegistry()

    // MARK: - Private Properties

    private var factories: [String: (BTJSON) throws -> BTNextAction] = [:]

    // MARK: - Initializer

    init() {
        registerThreeDSecureNextActions()
    }

    // MARK: - Internal Methods

    /// Registers a parsing closure for a `nextAction` union member, keyed on its GraphQL `__typename`.
    ///
    /// Not thread-safe — `factories` is a plain, unsynchronized dictionary on a shared singleton.
    /// This is only intended to be called at initialization time (e.g. from `init()`), before
    /// `resolve(json:)` is ever called concurrently; it is not safe to call at runtime alongside
    /// in-flight `resolve(json:)` calls.
    func register(typeName: String, factory: @escaping (BTJSON) throws -> BTNextAction) {
        factories[typeName] = factory
    }

    /// Resolves a `nextAction` JSON object into a `BTNextAction`, or `nil` if there is no `nextAction`.
    /// - Throws: `BTPaymentActionError.decodingFailure` if a recognized `__typename`'s required fields are missing.
    func resolve(json: BTJSON) throws -> BTNextAction? {
        guard json.asDictionary() != nil else {
            return nil
        }

        let typeName = json["__typename"].asString()

        guard let typeName, let factory = factories[typeName] else {
            return .unrecognized(typeName: typeName)
        }

        return try factory(json)
    }

    // MARK: - Private Methods

    private func registerThreeDSecureNextActions() {
        register(typeName: "PaymentActionThreeDSecureAuthentication") { json in
            guard let bin = json["bin"].asString(), !bin.isEmpty else {
                throw BTPaymentActionError.decodingFailure
            }

            return .threeDSecureAuthentication(BTPaymentActionThreeDSecureAuthenticationNextAction(bin: bin))
        }

        register(typeName: "PaymentActionThreeDSecureChallenge") { json in
            guard let acsURL = json["acsUrl"].asURL(),
                let challengePayload = json["challengePayload"].asString(),
                !challengePayload.isEmpty else {
                throw BTPaymentActionError.decodingFailure
            }

            return .threeDSecureChallenge(
                BTPaymentActionThreeDSecureChallengeNextAction(
                    acsURL: acsURL,
                    acsRenderingType: json["acsRenderingType"].asString(),
                    challengePayload: challengePayload,
                    mpiTransactionID: json["mpiTransactionId"].asString()
                )
            )
        }
    }
}
