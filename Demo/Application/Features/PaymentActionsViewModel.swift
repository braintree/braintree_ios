import SwiftUI
import BraintreePaymentActions

@MainActor
final class PaymentActionsViewModel: ObservableObject {

    // Card Form Fields
    @Published var cardNumber: String = ""
    @Published var expirationDate: String = ""
    @Published var cvv: String = ""
    @Published var postalCode: String = ""

    // Payment Action Options
    @Published var confirmationMode: PaymentActionMode = .automatic {
        didSet { optionsDidChange(from: oldValue, to: confirmationMode) }
    }
    @Published var captureMode: PaymentActionMode = .automatic {
        didSet { optionsDidChange(from: oldValue, to: captureMode) }
    }

    // UI State
    @Published var isPayButtonEnabled: Bool = false
    @Published var isCardFieldsEnabled: Bool = true
    @Published var isRunning: Bool = false
    @Published var outcome: PaymentOutcome?

    @Published var flow = PaymentFlowKind.threeDSecure {
        didSet { flowDidChange(from: oldValue) }
    }

    private let authorization: String
    private let onProgress: (String?) -> Void
    private var service: PaymentActionsFlowService

    // MARK: Initializer

    init(authorization: String, onProgress: @escaping (String?) -> Void = { _ in }) {
        self.authorization = authorization
        self.onProgress = onProgress
        self.service = PaymentActionsServiceFactory.make(flow: .threeDSecure)
    }

    // MARK: Lifecycle

    func onAppear() {
        createPaymentAction()
    }

    // MARK: Payment Action Setup

    func createPaymentAction() {
        isPayButtonEnabled = false
        outcome = nil
        onProgress("Creating Payment Action...")

        let options = PaymentActionOptions(confirmation: confirmationMode, capture: captureMode)
        Task { @MainActor in
            do {
                let paymentActionID = try await service.createPaymentAction(options: options)
                isPayButtonEnabled = true
                onProgress("Created Payment Action \(paymentActionID). Ready to pay.")
            } catch {
                onProgress("Failed to create Payment Action: \(error.localizedDescription)")
            }
        }
    }

    // MARK: Actions

    func tappedPay() {
        guard let card = makeCard() else {
            onProgress("Fill in all card fields.")
            return
        }

        let driver = PaymentFlowDriver(service: service, confirmation: confirmationMode) { [weak self] in
            self?.onProgress($0)
        }

        outcome = nil
        isRunning = true
        isCardFieldsEnabled = false

        Task { @MainActor in
            defer {
                isRunning = false
                isCardFieldsEnabled = true
            }
            do {
                let finalOutcome = try await driver.run(card: card)
                show(finalOutcome)
            } catch {
                onProgress("Payment failed: \(error.localizedDescription)")
            }
        }
    }

    func tappedAutofill() {
        cardNumber = flow == .threeDSecure ? "4000000000001091" : "4111111111111111"
        cvv = "123"
        expirationDate = CardHelpers.generateFuture(.date)
        postalCode = "94105"
    }

    // MARK: Private Methods

    private func show(_ finalOutcome: PaymentOutcome) {
        outcome = finalOutcome
        onProgress("Payment Action \(finalOutcome.paymentActionID) finished.")

        if finalOutcome.status == .declined {
            clearCardFields()
        }
    }

    /// A Payment Action is created with its modes fixed, so changing one means the current Payment Action
    /// no longer matches what's selected.
    private func optionsDidChange(from oldValue: PaymentActionMode, to newValue: PaymentActionMode) {
        guard oldValue != newValue else { return }
        isPayButtonEnabled = false
        onProgress("Options changed. Tap Get New Payment Action.")
    }

    private func flowDidChange(from oldValue: PaymentFlowKind) {
        guard oldValue != flow else { return }
        service = PaymentActionsServiceFactory.make(flow: flow)
        createPaymentAction()
    }

    private func clearCardFields() {
        cardNumber = ""
        expirationDate = ""
        cvv = ""
        postalCode = ""
    }

    /// Builds a `BTCreditCard` from the card form fields, or `nil` if a required field is
    /// missing/malformed. Mirrors the validation `CardTokenizationView.makeCard()` uses for the
    /// shared `CardFormView`, so both features stay in sync if the form's requirements change.
    private func makeCard() -> BTCreditCard? {
        guard !cardNumber.isEmpty, !cvv.isEmpty else { return nil }

        let parts = expirationDate.split(separator: "/")
        guard parts.count == 2,
            let month = parts.first,
            let year = parts.last,
            !month.isEmpty, !year.isEmpty else {
            return nil
        }

        (service as? HybridPaymentActionsFlowService)?.rawCard = PaymentCardDetails( // MOCK-REMOVAL
            number: cardNumber,
            expirationMonth: String(month),
            expirationYear: String(year),
            cvv: cvv
        )

        return BTCreditCard(
            cardNumber: cardNumber,
            expirationMonth: String(month),
            expirationYear: String(year),
            cvv: cvv,
            postalCode: postalCode.isEmpty ? nil : postalCode
        )
    }
}
