import Foundation

/// Owns the Payment Action status state machine for the `handleNextAction` drive loop.
///
/// Repeatedly fetches the current Payment Action and dispatches on its `status` until reaching a
/// terminal outcome or a handoff boundary (a server action or a customer action this SDK can't
/// resolve is required). The only status this loop re-polls internally is `.processing`.
///
/// At `.requiresCustomerAction`, if a `resolveCustomerAction` closure is provided and the Payment
/// Action's `nextAction` is a recognized 3D Secure member, the loop drives it (device data
/// collection or the challenge) and continues with the resulting Payment Action. If no resolver is
/// provided, or `nextAction` is `nil`/`.unrecognized`, the loop returns immediately rather than
/// looping — that's the boundary for input the SDK cannot gather itself.
final class NextActionHandler {

    // MARK: - Internal Types

    /// The outcome of driving a single customer action to completion.
    enum CustomerActionOutcome {
        /// The customer action was signaled complete; the Payment Action has advanced.
        case advanced(BTPaymentAction)

        /// The customer abandoned or timed out of the 3D Secure challenge. The Payment Action is
        /// still alive — the loop stops driving immediately rather than treating this as an error.
        case abandoned
    }

    /// Drives a single customer action (device data collection or a 3D Secure challenge) to
    /// completion, returning the resulting outcome.
    typealias ResolveCustomerAction = (BTNextAction) async throws -> CustomerActionOutcome

    /// The result of `drive()`: either the last-fetched Payment Action, or a distinct
    /// challenge-abandoned outcome that never reached a new server-recorded state.
    enum DriveResult: Equatable {
        case paymentAction(BTPaymentAction)
        case threeDSecureCanceled(id: String)
    }

    // MARK: - Internal Properties

    static let maxProcessingAttempts = 3
    static let processingRetryDelayNanoseconds: UInt64 = 1_000_000_000

    // MARK: - Private Properties

    private let fetchPaymentAction: () async throws -> BTPaymentAction
    private let resolveCustomerAction: ResolveCustomerAction?
    private let processingRetryDelayNanoseconds: UInt64

    // MARK: - Initializer

    /// - Parameter processingRetryDelayNanoseconds: exposed for testing so unit tests don't incur
    ///   the real retry delay; defaults to the production 1-second interval.
    /// - Parameter resolveCustomerAction: drives a recognized `nextAction` to completion. `nil` by
    ///   default, which preserves the original no-arg boundary behavior for callers that don't need it.
    init(
        processingRetryDelayNanoseconds: UInt64 = NextActionHandler.processingRetryDelayNanoseconds,
        fetchPaymentAction: @escaping () async throws -> BTPaymentAction,
        resolveCustomerAction: ResolveCustomerAction? = nil
    ) {
        self.processingRetryDelayNanoseconds = processingRetryDelayNanoseconds
        self.fetchPaymentAction = fetchPaymentAction
        self.resolveCustomerAction = resolveCustomerAction
    }

    // MARK: - Internal Methods

    /// Drives the Payment Action forward until it reaches a terminal state or a handoff boundary.
    /// - Returns: the last-fetched `BTPaymentAction` at a non-`.processing` status (or at
    ///   `.processing` if the bounded re-check attempts were exhausted), or `.threeDSecureCanceled`
    ///   if the customer abandoned or timed out of a challenge.
    /// - Throws: the underlying fetch/resolve error, or `BTPaymentActionError.versionAnomaly` if a
    ///   fetched `version` is lower than one already observed in this loop.
    func drive() async throws -> DriveResult {
        var paymentAction = try await fetchPaymentAction()
        var lastVersion: Int?
        var processingAttempts = 0

        while true {
            if let lastVersion, let version = paymentAction.version, version < lastVersion {
                throw BTPaymentActionError.versionAnomaly
            }
            lastVersion = paymentAction.version ?? lastVersion

            switch paymentAction.status {
            case .processing:
                processingAttempts += 1
                guard processingAttempts < Self.maxProcessingAttempts else {
                    return .paymentAction(paymentAction)
                }

                try await Task.sleep(nanoseconds: processingRetryDelayNanoseconds)
                paymentAction = try await fetchPaymentAction()

            case .requiresCustomerAction:
                guard let nextAction = paymentAction.nextAction else {
                    return .paymentAction(paymentAction)
                }

                switch nextAction {
                case .unrecognized:
                    return .paymentAction(paymentAction)

                case .threeDSecureAuthentication, .threeDSecureChallenge:
                    guard let resolveCustomerAction else {
                        return .paymentAction(paymentAction)
                    }

                    switch try await resolveCustomerAction(nextAction) {
                    case .advanced(let advanced):
                        paymentAction = advanced
                    case .abandoned:
                        return .threeDSecureCanceled(id: paymentAction.id)
                    }
                }

            default:
                return .paymentAction(paymentAction)
            }
        }
    }
}
