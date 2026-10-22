import Foundation

/// Owns the Payment Action status state machine for the `handleNextAction` drive loop.
///
/// Repeatedly fetches the current Payment Action and dispatches on its `status` until reaching a
/// terminal outcome or a handoff boundary (a server action or customer action is required). The
/// only status this loop re-polls internally is `.processing`; every other status — including
/// `.requiresCustomerAction` — is returned immediately without further looping. This is what
/// enforces the customer-action boundary: this handler never inspects `nextAction` or drives 3DS
/// itself, it only decides whether to keep polling or to hand back to the caller.
final class NextActionHandler {

    // MARK: - Internal Properties

    static let maxProcessingAttempts = 3
    static let processingRetryDelayNanoseconds: UInt64 = 1_000_000_000

    // MARK: - Private Properties

    private let fetchPaymentAction: () async throws -> BTPaymentAction
    private let processingRetryDelayNanoseconds: UInt64

    // MARK: - Initializer

    /// - Parameter processingRetryDelayNanoseconds: exposed for testing so unit tests don't incur
    ///   the real retry delay; defaults to the production 1-second interval.
    init(
        processingRetryDelayNanoseconds: UInt64 = NextActionHandler.processingRetryDelayNanoseconds,
        fetchPaymentAction: @escaping () async throws -> BTPaymentAction
    ) {
        self.processingRetryDelayNanoseconds = processingRetryDelayNanoseconds
        self.fetchPaymentAction = fetchPaymentAction
    }

    // MARK: - Internal Methods

    /// Drives the Payment Action forward until it reaches a terminal state or a handoff boundary.
    /// - Returns: the last-fetched `BTPaymentAction`, at a non-`.processing` status, or at
    ///   `.processing` if the bounded re-check attempts were exhausted.
    /// - Throws: the underlying fetch error, or `BTPaymentActionError.versionAnomaly` if a fetched
    ///   `version` is lower than one already observed in this loop.
    func drive() async throws -> BTPaymentAction {
        var lastVersion: Int?
        var processingAttempts = 0

        while true {
            let paymentAction = try await fetchPaymentAction()

            if let lastVersion, let version = paymentAction.version, version < lastVersion {
                throw BTPaymentActionError.versionAnomaly
            }
            lastVersion = paymentAction.version ?? lastVersion

            guard paymentAction.status == .processing else {
                return paymentAction
            }

            processingAttempts += 1
            guard processingAttempts < Self.maxProcessingAttempts else {
                return paymentAction
            }

            try await Task.sleep(nanoseconds: processingRetryDelayNanoseconds)
        }
    }
}
