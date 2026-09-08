import SwiftUI
import BraintreeCard
import BraintreePaymentActions

final class PaymentActionsViewModel: ObservableObject {
    
    // Card Form Fields
    @Published var cardNumber: String = ""
    @Published var expirationMonth: String = ""
    @Published var expirationYear: String = ""
    @Published var cvv: String = ""
    @Published var postalCode: String = ""
    
    // UI State
    @Published var progressMessage: String = ""
    @Published var isPayEnabled: Bool = false
    @Published var isFieldsEnabled: Bool = false
    
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
        isPayEnabled = false
        progressMessage = "Fetching Payment Action Client Token..."
        
        // TODO: Add fetchPaymentActionClientToken(completion:) to BraintreeDemoMerchantAPIClient.
        
        BraintreeDemoMerchantAPIClient.shared.createCustomerAndFetchClientToken { [weak self] response, error in
            guard let self else { return }
            
            Task { @MainActor in
                if let error {
                    self.progressMessage = "Failed to fetch client token: \(error.localizedDescription)"
                    return
                }
                
                guard response != nil else {
                    self.progressMessage = "Failed to fetch client token"
                    return
                }
                // TODO: Set this once confirmationMethod/captureMethod are available on the response.
                // self.paymentActionConfigText = "confirmationMethod: \(response.confirmationMethod) · captureMethod: \(response.captureMethod)"
                self.isPayEnabled = true
                self.progressMessage = "Fetched client token. Ready to pay."
            }
        }
    }
    
    // MARK: Actions
    
    func tappedPay() {
        progressMessage = "Submitting payment method for Payment Action.."
        
        guard !cvv.isEmpty else {
            progressMessage = " Fill in all card fields."
            return
        }
        
        let request = BTCreditCard(
            cardNumber: cardNumber,
            expirationMonth: expirationMonth,
            expirationYear: expirationYear,
            cvv: cvv,
            postalCode: postalCode.isEmpty ? nil : postalCode
        )
        
        isFieldsEnabled = false
        
        Task { @MainActor in
            do {
                let result = try await paymentActionsClient.submitForPaymentAction(request)
                isFieldsEnabled = true
                try await handle(result)
            } catch {
                isFieldsEnabled = true
                progressMessage = "Failed to submit payment method: \(error.localizedDescription)"
            }
        }
    }
    
    func tappedAutofill() {
        cardNumber = "4111111111111111"
        cvv = "123"
        expirationMonth = "12"
        expirationYear = String(Calendar.current.component(.year, from: Date()) + 2)
        postalCode = "94105"
    }
    
    // MARK: Result Handling
    
    private func handle(_ result: BTPaymentActionResult) async throws {
        switch result.type {
        case .completed:
            showOrderConfirmation(paymentActionId: result.id)
            
        case .serverActionRequired:
            switch result.serverAction {
            case .confirm:
                progressMessage = "Notifying server to confirm Payment Action \(result.id)..."
                try await notifyServerToConfirm(paymentActionId: result.id)
                showOrderConfirmation(paymentActionId: result.id)
            case .capture:
                // Authorized; capture is pending server-side.
                showOrderConfirmation(paymentActionId: result.id)
            case nil:
                progressMessage = "Server action required but none was specified."
            case .some:
                progressMessage = "Server action unknown."
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
    
    private func showOrderConfirmation(paymentActionId: String) {
        progressMessage = "Payment Action \(paymentActionId) complete ✅"
    }
    
    private func showDeclineMessage() {
        progressMessage = "Payment method declined. Please try another card."
    }
    
    /// Asks the merchant server to confirm a Payment Action that requires it.
    private func notifyServerToConfirm(paymentActionId: String) async throws {
        // TODO: Add confirmPaymentAction(id:) to BraintreeDemoMerchantAPIClient.
        // Should hit the sample-merchant server's confirm endpoint for the given Payment Action id.
        // try await BraintreeDemoMerchantAPIClient.shared.confirmPaymentAction(id: paymentActionId)
    }
    
    private func clearCardFields() {
        cardNumber = ""
        cvv = ""
    }
}

// MARK: - View

struct PaymentActionsView: View {
    
    @StateObject private var viewModel: PaymentActionsViewModel
    
    init(authorization: String) {
        _viewModel = StateObject(wrappedValue: PaymentActionsViewModel(authorization: authorization))
    }
    
    var body: some View {
        Form {
            Section("Card Details") {
                TextField("Card Number", text: $viewModel.cardNumber)
                    .keyboardType(.numberPad)
                    .disabled(!viewModel.isFieldsEnabled)
                
                HStack {
                    TextField("MM", text: $viewModel.expirationMonth)
                        .keyboardType(.numberPad)
                    TextField("YYYY", text: $viewModel.expirationYear)
                        .keyboardType(.numberPad)
                }
                .disabled(!viewModel.isFieldsEnabled)
                
                TextField("CVV", text: $viewModel.cvv)
                    .keyboardType(.numberPad)
                    .disabled(!viewModel.isFieldsEnabled)
                
                TextField("Postal Code", text: $viewModel.postalCode)
                    .disabled(!viewModel.isFieldsEnabled)
                
                Button("Autofill") {
                    viewModel.tappedAutofill()
                }
                .disabled(!viewModel.isFieldsEnabled)
            }
            
            Section("Payment Actions Flow") {
                Text(viewModel.paymentActionConfigText)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                
                Button("Get New Payment Action") {
                    viewModel.fetchClientToken()
                }
                
                Button("Pay") {
                    viewModel.tappedPay()
                }
                .disabled(!viewModel.isPayEnabled)
            }
            
            if !viewModel.progressMessage.isEmpty {
                Section {
                    Text(viewModel.progressMessage)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Payment Actions")
        .onAppear {
            viewModel.onAppear()
        }
    }
}
