import SwiftUI
import BraintreePaymentActions

final class PaymentActionsViewModel: ObservableObject {

    // Card Form Fields
    @Published var cardNumber: String = ""
    @Published var expirationDate: String = ""
    @Published var cvv: String = ""
    @Published var postalCode: String = ""

    // UI State
    @Published var progressMessage: String = ""
    @Published var isPayButtonEnabled: Bool = false
    @Published var isCardFieldsEnabled: Bool = true

    /// Reflects the confirmationMethod/captureMethod that came back on the `paymentActions` field
    /// off the most recently fetched client token.
    @Published var paymentActionConfigText = "confirmationMethod: — · captureMethod: —"

    private let authorization: String
    private lazy var paymentActionsClient = BTPaymentActionsClient(authorization: authorization)

    // MARK: Initializer

    init(authorization: String) {
        self.authorization = authorization
    }

    // MARK: Lifecycle

    func onAppear() {
        fetchClientToken()
    }

    // MARK: Client Token / Client Setup

    func fetchClientToken() {
        isPayButtonEnabled = false
        progressMessage = "Fetching Payment Action Client Token..."

        let confirmationMethod = "AUTOMATIC"
        let captureMethod = "AUTOMATIC"

        BraintreeDemoMerchantAPIClient.shared.fetchPaymentActionClientToken(
            amount: "10.00",
            merchantAccountID: BraintreeDemoSettings.sandboxMerchantAccountID,
            confirmationMethod: confirmationMethod,
            captureMethod: captureMethod
        ) { [weak self] response, error in
            guard let self else { return }
            let response = response
            let error = error

            Task { @MainActor in
                if let error {
                    self.progressMessage = "Failed to fetch client token: \(error.localizedDescription)"
                    return
                }

                guard response != nil else {
                    self.progressMessage = "Failed to fetch client token"
                    return
                }

                self.paymentActionConfigText = "confirmationMethod: \(confirmationMethod) · captureMethod: \(captureMethod)"
                self.isPayButtonEnabled = true
                self.progressMessage = "Fetched client token. Ready to pay."
            }
        }
    }

    // MARK: Actions

    func tappedPay() {
        progressMessage = "Submitting payment method for Payment Action.."

        guard let request = makeCard() else {
            progressMessage = "Fill in all card fields."
            return
        }

        isCardFieldsEnabled = false

        Task { @MainActor in
            do {
                let result = try await paymentActionsClient.submitForPaymentAction(request)
                isCardFieldsEnabled = true
                try await handle(result)
            } catch {
                isCardFieldsEnabled = true
                progressMessage = "Failed to submit payment method: \(error.localizedDescription)"
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
            switch result.serverAction {
            case .confirm:
                progressMessage = "Notifying server to confirm Payment Action \(result.id)..."
                try await notifyServerToConfirm(paymentActionID: result.id)
                showOrderConfirmation(paymentActionID: result.id)
            case .capture:
                // Authorized; capture is pending server-side.
                showOrderConfirmation(paymentActionID: result.id)
            case nil:
                progressMessage = "Server action required but none was specified."
            }

        case .paymentMethodRequired:
            clearCardFields()
            showDeclineMessage()

        case .customerActionRequired, .processing, .canceled, .expired, .unknown:
            progressMessage = "Payment Action \(result.id): \(result.type)"
        @unknown default:
            progressMessage = "Payment Action \(result.id) case not handled."
        }
    }

    private func showOrderConfirmation(paymentActionID: String) {
        progressMessage = "Payment Action \(paymentActionID) complete ✅"
    }

    private func showDeclineMessage() {
        progressMessage = "Payment method declined. Please try another card."
    }

    /// Asks the merchant server to confirm a Payment Action that requires it.
    private func notifyServerToConfirm(paymentActionID: String) async throws {
        // TODO: Add confirmPaymentAction(id:) to BraintreeDemoMerchantAPIClient.
        // Should hit the sample-merchant server's confirm endpoint for the given Payment Action id.
        // try await BraintreeDemoMerchantAPIClient.shared.confirmPaymentAction(id: paymentActionID)
    }

    private func clearCardFields() {
        cardNumber = ""
        expirationDate = ""
        cvv = ""
        postalCode = ""
    }

    /// Builds a `BTCreditCard` from the card form fields, or `nil` if a required field is missing/malformed.
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
