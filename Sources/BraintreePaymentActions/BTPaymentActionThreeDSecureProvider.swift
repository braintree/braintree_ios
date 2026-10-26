import Foundation
import CardinalMobile
import UIKit

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// A mockable seam over `UIApplication.shared.applicationState`, so the foreground gate can be unit
/// tested without touching the real application state.
protocol ApplicationStateProviding {

    var isApplicationActive: Bool { get }
}

extension UIApplication: ApplicationStateProviding {

    var isApplicationActive: Bool {
        applicationState == .active
    }
}

/// Owns the Cardinal session and every CardinalMobile call for the M4 3D Secure customer-action flow.
/// No Cardinal type escapes this wrapper — callers only see `String`/`ChallengeOutcome` and
/// `BTPaymentActionError`.
///
/// Built as a new type rather than reusing the legacy 3DS module's `BTThreeDSecureV2Provider`, so the
/// M4 drive path's presentation requirements — a foreground guarantee, a watchdog, and full Cardinal
/// action-code coverage — can be added with zero regression risk to the still-shipping legacy flow.
/// Duplicates `BTThreeDSecureV2Provider`'s Cardinal setup sequence rather than sharing it, per the
/// isolation decision in the Cardinal challenge spike.
final class BTPaymentActionThreeDSecureProvider {

    // MARK: - Internal Types

    /// The lifecycle state of an in-flight Cardinal interaction, guarding against re-entrant calls.
    enum State: Equatable {
        case idle
        case collectingDeviceData
        case presentingChallenge
    }

    /// The outcome of presenting a 3D Secure challenge.
    enum ChallengeOutcome: Equatable {
        /// Cardinal validated the challenge — successfully, with no action needed, or with a reported
        /// failure the server makes the final call on (matching the legacy flow's treatment of
        /// `.failure`) — and returned a server JWT to report via `signalCustomerActionComplete`.
        case validated(serverJWT: String)

        /// The customer abandoned or timed out of the challenge. The Payment Action is still alive
        /// and retryable; this is never surfaced as a plain cancel.
        case abandoned
    }

    // MARK: - Internal Static Properties

    static let challengeWatchdogTimeoutNanoseconds: UInt64 = 60_000_000_000

    // MARK: - Internal Properties

    /// Exposed for testing to force a re-entrancy scenario.
    var state: State = .idle

    // MARK: - Private Properties

    private let cardinalSession: CardinalSessionTestable
    private let cardinalAuthenticationJWT: String
    private let challengeWatchdogTimeoutNanoseconds: UInt64
    // nonisolated(unsafe): read-only access to UIApplication's state, same pattern as
    // BTVenmoClient's `application: URLOpener` seam — never mutated after init.
    private nonisolated(unsafe) let applicationStateProvider: ApplicationStateProviding
    private var challengeContinuation: CheckedContinuation<ChallengeOutcome, Error>?

    // MARK: - Initializer

    /// - Throws: `BTPaymentActionError.missingCardinalAuthenticationJWT` if `configuration` has no
    ///   Cardinal authentication JWT.
    init(
        configuration: BTConfiguration,
        cardinalSession: CardinalSessionTestable = CardinalSession(),
        applicationStateProvider: ApplicationStateProviding = UIApplication.shared,
        challengeWatchdogTimeoutNanoseconds: UInt64 = BTPaymentActionThreeDSecureProvider.challengeWatchdogTimeoutNanoseconds
    ) throws {
        guard let cardinalAuthenticationJWT = configuration.cardinalAuthenticationJWT else {
            throw BTPaymentActionError.missingCardinalAuthenticationJWT
        }

        self.cardinalSession = cardinalSession
        self.cardinalAuthenticationJWT = cardinalAuthenticationJWT
        self.applicationStateProvider = applicationStateProvider
        self.challengeWatchdogTimeoutNanoseconds = challengeWatchdogTimeoutNanoseconds

        let cardinalConfiguration = CardinalSessionConfiguration()
        cardinalConfiguration.deploymentEnvironment = configuration.environment == "production" ? .production : .staging
        // `collectLogs` is intentionally left unset, matching the legacy 3DS flow's existing behavior.
        cardinalSession.configure(cardinalConfiguration)
    }

    // MARK: - Internal Methods

    /// Runs Cardinal's device data collection step.
    ///
    /// The `PaymentActionThreeDSecureAuthentication` `nextAction`'s `bin` field is not used here —
    /// confirmed with the Payment Actions backend team that `bin` is needed by the web SDK's device
    /// data collection step only; CardinalMobile's non-deprecated `setup` overload on iOS/Android
    /// takes no account number at all.
    /// - Returns: the `dfReferenceId` to report via `signalCustomerActionComplete(.deviceDataCollection(...))`.
    /// - Throws: `BTPaymentActionError.cardinalInteractionAlreadyInProgress` if a previous call on this
    ///   instance hasn't completed, or `.cardinalSetupValidationFailed` if Cardinal rejects the JWT.
    func collectDeviceData() async throws -> String {
        guard state == .idle else {
            throw BTPaymentActionError.cardinalInteractionAlreadyInProgress
        }

        state = .collectingDeviceData
        defer { state = .idle }

        return try await withCheckedThrowingContinuation { continuation in
            cardinalSession.setup(
                jwtString: cardinalAuthenticationJWT,
                completed: { dfReferenceID in
                    continuation.resume(returning: dfReferenceID)
                },
                validated: { _ in
                    continuation.resume(throwing: BTPaymentActionError.cardinalSetupValidationFailed)
                }
            )
        }
    }

    /// Presents the 3D Secure challenge via Cardinal, gated on the app being foregrounded and bounded
    /// by a watchdog so a silent Cardinal failure can never hang the caller indefinitely.
    /// - Throws: `BTPaymentActionError.cardinalInteractionAlreadyInProgress` if a previous call on this
    ///   instance hasn't completed, `.foregroundRequired` if the app isn't active,
    ///   `.cardinalChallengeTimedOut` if the watchdog elapses first, `.cardinalChallengeFailed` for a
    ///   Cardinal-reported `.error`, or `.unrecognizedCardinalActionCode` for an unknown action code.
    func presentChallenge(transactionID: String, payload: String) async throws -> ChallengeOutcome {
        guard state == .idle else {
            throw BTPaymentActionError.cardinalInteractionAlreadyInProgress
        }

        // Confirmed required by the Cardinal challenge spike's live reproduction: calling into
        // Cardinal while backgrounded doesn't present the challenge — it silently redirects to an
        // external Safari app-switch prompt the customer can ignore.
        guard applicationStateProvider.isApplicationActive else {
            throw BTPaymentActionError.foregroundRequired
        }

        state = .presentingChallenge
        defer { state = .idle }

        // The watchdog resolves the same continuation directly (via `resolveChallenge`) rather than
        // racing it in a second `TaskGroup` child task: Cardinal's `continueWith` offers no
        // cancellation hook, so a `CheckedContinuation` that never gets resumed would otherwise hang
        // forever — including hanging a `TaskGroup`'s implicit await-all-children at scope exit.
        return try await withCheckedThrowingContinuation { continuation in
            self.challengeContinuation = continuation
            self.cardinalSession.continueWith(
                transactionId: transactionID,
                payload: payload,
                validationDelegate: self
            )

            Task { [challengeWatchdogTimeoutNanoseconds] in
                try? await Task.sleep(nanoseconds: challengeWatchdogTimeoutNanoseconds)
                self.resolveChallengeTimedOut()
            }
        }
    }
}

// MARK: - CardinalValidationDelegate

extension BTPaymentActionThreeDSecureProvider: CardinalValidationDelegate {

    // swiftlint:disable implicitly_unwrapped_optional
    func cardinalSession(
        cardinalSession session: CardinalSession!,
        stepUpValidated validateResponse: CardinalResponse!,
        serverJWT: String!
    ) {
        // swiftlint:enable implicitly_unwrapped_optional
        resolveChallenge(actionCode: validateResponse.actionCode, serverJWT: serverJWT)
    }

    /// The actual action-code mapping, split out from the `CardinalValidationDelegate` callback so it
    /// can be unit tested directly against `CardinalResponseActionCode` — `CardinalResponse` itself
    /// has no accessible initializer and can't be constructed in test code.
    func resolveChallenge(actionCode: CardinalResponseActionCode, serverJWT: String) {
        guard let continuation = challengeContinuation else { return }
        challengeContinuation = nil

        switch actionCode {
        case .success, .noAction, .failure:
            continuation.resume(returning: .validated(serverJWT: serverJWT))
        case .cancel, .timeout:
            continuation.resume(returning: .abandoned)
        case .error:
            continuation.resume(throwing: BTPaymentActionError.cardinalChallengeFailed)
        @unknown default:
            continuation.resume(throwing: BTPaymentActionError.unrecognizedCardinalActionCode)
        }
    }

    /// Resolves the pending challenge continuation with a timeout error if Cardinal hasn't already
    /// resolved it by the time the watchdog elapses. A no-op if Cardinal already called back first.
    func resolveChallengeTimedOut() {
        guard let continuation = challengeContinuation else { return }
        challengeContinuation = nil
        continuation.resume(throwing: BTPaymentActionError.cardinalChallengeTimedOut)
    }
}
