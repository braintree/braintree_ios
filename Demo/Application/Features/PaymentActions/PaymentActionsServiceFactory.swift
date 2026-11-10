import Foundation

// TODO: Once the real backend is ready, delete the `Mock/` folder, remove every line tagged `MOCK-REMOVAL`
// (grep for it), point `.threeDSecure` at `LivePaymentActionsFlowService` with 3DS requested from the
// sample merchant, and drop the Podfile's OHHTTPStubs line.

/// Which Payment Actions journey the screen demonstrates.
enum PaymentFlowKind: String, CaseIterable, Identifiable {

    case card
    case threeDSecure

    var id: String { rawValue }

    var title: String {
        switch self {
        case .card: return "Card"
        case .threeDSecure: return "3DS"
        }
    }
}

@MainActor
enum PaymentActionsServiceFactory {

    static func make(flow: PaymentFlowKind) -> PaymentActionsFlowService {
        switch flow {
        case .card:
            return LivePaymentActionsFlowService()
        case .threeDSecure:
            return HybridPaymentActionsFlowService() // MOCK-REMOVAL
        }
    }
}
