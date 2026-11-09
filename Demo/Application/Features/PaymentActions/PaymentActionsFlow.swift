import Foundation

/// Whether the merchant (or the Payment Actions server) performs a step automatically or on demand.
enum PaymentActionMode: String, CaseIterable, Identifiable {

    case automatic = "AUTOMATIC"
    case manual = "MANUAL"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .automatic: return "Auto"
        case .manual: return "Manual"
        }
    }
}

struct PaymentActionOptions: Equatable {

    var confirmation: PaymentActionMode = .automatic
    var capture: PaymentActionMode = .automatic
}

struct PaymentCardDetails: Equatable {

    let number: String
    let expirationMonth: String
    let expirationYear: String
    let cvv: String
    let postalCode: String?
}

/// What the shopper and merchant see at the end of a step, independent of where it came from.
enum PaymentOutcome: Equatable {

    case success(id: String)
    case capturePending(id: String)
    case declined(id: String)
    case threeDSecureCanceled(id: String)
    case canceled(id: String)
    case expired(id: String)
    case unrecognized(id: String)
    case processing(id: String)
    case customerActionRequired(id: String)
    case confirmationRequired(id: String)
}

enum PaymentActionsDemoError: LocalizedError {

    case clientTokenUnavailable
    case noActivePaymentAction
    case confirmRouteUnavailable
    case unexpectedState

    var errorDescription: String? {
        switch self {
        case .clientTokenUnavailable:
            return "The sample merchant didn't return a client token."
        case .noActivePaymentAction:
            return "Create a Payment Action first."
        case .confirmRouteUnavailable:
            return "The sample merchant's confirm route isn't available yet."
        case .unexpectedState:
            return "The Payment Action isn't in a state that allows this step. Get a new Payment Action."
        }
    }
}

/// The only thing `PaymentActionsViewModel` knows about where Payment Actions come from, so the
/// backend can be swapped without touching the screen.
@MainActor
protocol PaymentActionsFlowService: AnyObject {

    func createPaymentAction(options: PaymentActionOptions) async throws -> String

    func submit(card: PaymentCardDetails) async throws -> PaymentOutcome

    /// Plays the merchant server confirming the Payment Action.
    func confirm(paymentActionID: String) async throws

    func handleNextAction() async throws -> PaymentOutcome
}
