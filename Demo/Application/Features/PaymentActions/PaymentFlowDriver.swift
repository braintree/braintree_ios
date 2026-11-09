import Foundation

/// Runs one payment from card submission to a final outcome, playing the merchant for MANUAL
/// confirmation. After every confirm it re-enters via `handleNextAction` instead of assuming the
/// payment completed.
@MainActor
struct PaymentFlowDriver {

    static let maxSteps = 5

    let service: PaymentActionsFlowService
    let confirmation: PaymentActionMode
    let onProgress: (String) -> Void

    func run(card: PaymentCardDetails) async throws -> PaymentOutcome {
        onProgress("Submitting payment method...")
        var outcome = try await service.submit(card: card)
        var isSubmitResult = true

        for _ in 0..<Self.maxSteps {
            switch outcome {
            case .confirmationRequired(let id) where confirmation == .manual:
                onProgress("Merchant confirming Payment Action...")
                try await service.confirm(paymentActionID: id)
                onProgress("Continuing from the Payment Action's state...")
                outcome = try await service.handleNextAction()
                isSubmitResult = false

            case .customerActionRequired, .processing:
                // A result from `handleNextAction` is final here: the SDK already drove what it can,
                // so calling it again would loop without making progress.
                guard isSubmitResult else { return outcome }
                onProgress("Driving the next action...")
                outcome = try await service.handleNextAction()
                isSubmitResult = false

            default:
                return outcome
            }
        }
        return outcome
    }
}
