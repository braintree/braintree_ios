import Foundation
import BraintreePaymentActions

/// Talks to the real SDK and the sample merchant server.
@MainActor
class LivePaymentActionsFlowService: PaymentActionsFlowService {

    private var client: BTPaymentActionsClient?

    /// The client token the active `BTPaymentActionsClient` was created with.
    private(set) var clientToken: String?

    func createPaymentAction(options: PaymentActionOptions) async throws -> String {
        let credentials = try await fetchCredentials(options: options)

        let launchOptions = BTPaymentActionThreeDSecureOptions()
        launchOptions.requestorAppURL = URL(string: "com.braintreepayments.Demo.payments://")
        client = BTPaymentActionsClient(
            authorization: credentials.clientToken,
            threeDSecureLaunchOptions: launchOptions
        )
        clientToken = credentials.clientToken
        return credentials.paymentActionID
    }

    /// Where the client token and Payment Action ID come from. Overridden by the hybrid backend.
    func fetchCredentials(options: PaymentActionOptions) async throws -> (clientToken: String, paymentActionID: String) {
        let response: BraintreeDemoMerchantAPIClient.PaymentActionResponse = try await withCheckedThrowingContinuation { continuation in
            BraintreeDemoMerchantAPIClient.shared.fetchPaymentActionClientToken(
                amount: "10.00",
                merchantAccountID: BraintreeDemoSettings.sandboxMerchantAccountID,
                confirmationMethod: options.confirmation.rawValue,
                captureMethod: options.capture.rawValue
            ) { response, error in
                if let response {
                    continuation.resume(returning: response)
                } else {
                    continuation.resume(throwing: error ?? PaymentActionsDemoError.clientTokenUnavailable)
                }
            }
        }
        return (response.clientToken, response.paymentAction.id)
    }

    func submit(card: PaymentCardDetails) async throws -> PaymentOutcome {
        guard let client else { throw PaymentActionsDemoError.noActivePaymentAction }

        let request = BTCreditCard(
            cardNumber: card.number,
            expirationMonth: card.expirationMonth,
            expirationYear: card.expirationYear,
            cvv: card.cvv,
            postalCode: card.postalCode
        )
        return PaymentOutcome(try await client.submitForPaymentAction(request))
    }

    func confirm(paymentActionID: String) async throws {
        throw PaymentActionsDemoError.confirmRouteUnavailable
    }

    func handleNextAction() async throws -> PaymentOutcome {
        guard let client else { throw PaymentActionsDemoError.noActivePaymentAction }
        return PaymentOutcome(try await client.handleNextAction())
    }
}

private extension PaymentOutcome {

    init(_ result: BTPaymentActionResult) {
        let id = result.id
        switch result.type {
        case .completed:
            self = .success(id: id)
        case .serverActionRequired:
            let serverAction = (result as? BTServerActionRequiredResult)?.serverAction
            self = serverAction == .capture ? .capturePending(id: id) : .confirmationRequired(id: id)
        case .paymentMethodRequired:
            self = .declined(id: id)
        case .customerActionRequired:
            self = .customerActionRequired(id: id)
        case .threeDSecureCanceled:
            self = .threeDSecureCanceled(id: id)
        case .canceled:
            self = .canceled(id: id)
        case .expired:
            self = .expired(id: id)
        case .processing:
            self = .processing(id: id)
        case .unrecognized:
            self = .unrecognized(id: id)
        @unknown default:
            self = .unrecognized(id: id)
        }
    }
}
