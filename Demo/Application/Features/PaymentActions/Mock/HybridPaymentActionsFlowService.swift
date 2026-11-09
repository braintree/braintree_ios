import Foundation
import BraintreeCard

struct HybridStepError: LocalizedError {

    let step: String
    let detail: String

    var errorDescription: String? { "\(step) failed: \(detail)" }
}

/// The real SDK and real Cardinal, with only the Payment Actions server stubbed. Uses a real client
/// token from the sample merchant, since the server-created Payment Action isn't available yet.
@MainActor
final class HybridPaymentActionsFlowService: LivePaymentActionsFlowService {

    private let stub = HybridPaymentActionsStub()

    override func fetchCredentials(
        options: PaymentActionOptions
    ) async throws -> (clientToken: String, paymentActionID: String) {
        let clientToken: String = try await attempt("Fetching client token") {
            try await withCheckedThrowingContinuation { continuation in
                BraintreeDemoMerchantAPIClient.shared.createCustomerAndFetchClientToken { token, error in
                    if let token {
                        continuation.resume(returning: token)
                    } else {
                        continuation.resume(throwing: error ?? PaymentActionsDemoError.clientTokenUnavailable)
                    }
                }
            }
        }
        return (clientToken, stub.begin(options: options, clientToken: clientToken))
    }

    override func submit(card: PaymentCardDetails) async throws -> PaymentOutcome {
        guard let clientToken else { throw PaymentActionsDemoError.noActivePaymentAction }

        // The Gateway lookup that supplies the real challenge payload needs a tokenized card.
        let tokenizedCard = BTCard(
            number: card.number,
            expirationMonth: card.expirationMonth,
            expirationYear: card.expirationYear,
            cvv: card.cvv
        )
        let nonce = try await attempt("Tokenizing card") {
            try await BTCardClient(authorization: clientToken).tokenize(tokenizedCard).nonce
        }
        stub.setPaymentMethod(nonce: nonce, bin: String(card.number.prefix(6)))

        return try await attempt("Submitting to Payment Actions") { try await super.submit(card: card) }
    }

    override func handleNextAction() async throws -> PaymentOutcome {
        try await attempt("Driving the next action") { try await super.handleNextAction() }
    }

    override func confirm(paymentActionID: String) async throws {
        try stub.confirm()
    }

    // MARK: - Private Methods

    /// Labels a failure with the step it happened in, preferring the stub's own explanation when it was
    /// the stub that failed the request.
    private func attempt<T>(_ step: String, _ body: () async throws -> T) async throws -> T {
        do {
            return try await body()
        } catch {
            throw HybridStepError(step: step, detail: stub.takeLastFailure() ?? HybridPaymentActionsStub.describe(error))
        }
    }
}
