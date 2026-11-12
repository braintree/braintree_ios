import Foundation
import BraintreePaymentActions

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

/// What the shopper and merchant see at the end of a step, independent of where it came from.
struct PaymentOutcome: Equatable {

    enum Status: Equatable {
        case success
        case capturePending
        case declined
        case threeDSecureCanceled
        case canceled
        case expired
        case unrecognized
        case processing
        case customerActionRequired
        case confirmationRequired
    }

    let status: Status
    let paymentActionID: String
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

    func submit(card: BTCreditCard) async throws -> PaymentOutcome

    /// Plays the merchant server confirming the Payment Action.
    func confirm(paymentActionID: String) async throws

    func handleNextAction() async throws -> PaymentOutcome
}
