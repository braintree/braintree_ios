import SwiftUI
import BraintreePaymentActions

final class PaymentActionsViewModel: ObservableObject {

    // Card Form Fields
    @Published var cardNumber: String = ""
    @Published var expirationDate: String = ""
    @Published var cvv: String = ""
    @Published var postalCode: String = ""

    // UI State
    @Published var isPayButtonEnabled: Bool = false
    @Published var isCardFieldsEnabled: Bool = true

    private let authorization: String
    private let onProgress: (String?) -> Void
    private var paymentActionsClient: BTPaymentActionsClient?

    // MARK: Initializer

    init(authorization: String, onProgress: @escaping (String?) -> Void = { _ in }) {
        self.authorization = authorization
        self.onProgress = onProgress
    }

    // MARK: Lifecycle

    func onAppear() {
        fetchClientToken()
    }

    // MARK: Client Token / Client Setup

    func fetchClientToken() {
        isPayButtonEnabled = false
        onProgress("Fetching Payment Action Client Token...")

        BraintreeDemoMerchantAPIClient.shared.fetchPaymentActionClientToken(
            amount: "10.00",
            merchantAccountID: BraintreeDemoSettings.sandboxMerchantAccountID,
            confirmationMethod: "AUTOMATIC",
            captureMethod: "AUTOMATIC"
        ) { [weak self] response, error in
            guard let self else { return }

            Task { @MainActor in
                if let error {
                    self.onProgress("Failed to fetch client token: \(error.localizedDescription)")
                    return
                }

                guard let response else {
                    self.onProgress("Failed to fetch client token")
                    return
                }

                self.paymentActionsClient = BTPaymentActionsClient(authorization: response.clientToken)
                self.isPayButtonEnabled = true
                self.onProgress("Fetched client token. Ready to pay.")
            }
        }
    }

    // MARK: Actions

    func tappedPay() {
        onProgress("Submitting payment method for Payment Action.")

        guard let paymentActionsClient else {
            onProgress("Fetch a Payment Action Client Token first.")
            return
        }

        guard let request = makeCard() else {
            onProgress("Fill in all card fields.")
            return
        }

        isCardFieldsEnabled = false

        Task { @MainActor in
            defer { isCardFieldsEnabled = true }
            do {
                let result = try await paymentActionsClient.submitForPaymentAction(request)
                try await handle(result)
            } catch {
                isCardFieldsEnabled = true
                onProgress("Failed to submit payment method: \(error.localizedDescription)")
            }
        }
    }

    func tappedAutofill() {
        cardNumber = "4111111111111111"
        cvv = "123"
        expirationDate = CardHelpers.generateFuture(.date)
        postalCode = "94105"
    }

    // MARK: Result Handling

    private func handle(_ result: BTPaymentActionResult) async throws {
        switch result.type {
        case .completed:
            showOrderConfirmation(paymentActionID: result.id)
        case .serverActionRequired:
            guard let result = result as? BTServerActionRequiredResult else {
                onProgress("Unexpected result: missing server action")
                return
            }
            try await handle(serverAction: result.serverAction, paymentActionID: result.id)
        case .paymentMethodRequired:
            clearCardFields()
            showDeclineMessage()
        case .customerActionRequired, .processing, .canceled, .expired, .unknown:
            onProgress("Payment Action \(result.id): \(result.type)")
        @unknown default:
            onProgress("Payment Action \(result.id) case not handled.")
        }
    }

    /// Handles the server-driven action a `BTServerActionRequiredResult` carries.
    private func handle(serverAction: BTServerAction, paymentActionID: String) async throws {
        switch serverAction {
        case .confirm:
            onProgress("Notifying server to confirm Payment Action \(paymentActionID)...")
            showOrderConfirmation(paymentActionID: paymentActionID)
        case .capture:
            // Authorized; capture is pending server-side.
            showOrderConfirmation(paymentActionID: paymentActionID)
        }
    }

    private func showOrderConfirmation(paymentActionID: String) {
        onProgress("Payment Action \(paymentActionID) complete ✅")
    }

    private func showDeclineMessage() {
        onProgress("Payment method declined. Please try another card.")
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

        return BTCreditCard(
            cardNumber: cardNumber,
            expirationMonth: String(month),
            expirationYear: String(year),
            cvv: cvv,
            postalCode: postalCode.isEmpty ? nil : postalCode
        )
    }
}
