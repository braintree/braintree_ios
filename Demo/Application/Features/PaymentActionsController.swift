import UIKit
import BraintreeCard
import BraintreePaymentActions

class PaymentActionsViewController: PaymentButtonBaseViewController {
    
    // MARK: - Private Properties
    
    private let cardFormView = BTCardFormView()
    private var autofillButton = UIButton(type: .system)
    private var payButton = UIButton(type: .system)
    private var refreshButton = UIButton(type: .system)
    
    /// Read-only: reflects the confirmationMethod/captureMethod that came back on the
    /// `paymentActions` field of the most recently fetched client token.
    private let paymentActionConfigLabel = UILabel()
    
    private lazy var paymentActionsClient = BTPaymentActionsClient(authorization: authorization)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.heightConstraint = 260
        super.viewDidLoad()
        
        title = "Payment Actions"
        
        createSubviews()
        layoutConstraints()
        
        // Fetch a Payment-Action-scoped client token and re-initialize the client eagerly, so
        // gateway config is prefetched before the customer taps Pay.
        fetchClientToken()
    }
    
    override func createPaymentButton() -> UIView {
        payButton = createButton(title: "Pay", action: #selector(tappedPay))
        refreshButton = createButton(title: "Get New Payment Action", action: #selector(tappedRefresh))
        
        paymentActionConfigLabel.font = .systemFont(ofSize: 13)
        paymentActionConfigLabel.textColor = .secondaryLabel
        paymentActionConfigLabel.numberOfLines = 0
        paymentActionConfigLabel.text = "confirmationMethod: — · captureMethod: —"
        
        let stackView = buttonsStackView(label: "Payment Actions Flow", views: [
            paymentActionConfigLabel,
            refreshButton,
            payButton
        ])
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }
    
    // MARK: - Client Token / Client Setup
    
    /// Fetches a client token scoped to a Payment Action, reads the confirmationMethod/
    /// captureMethod the server assigned to it off the `paymentActions` field of the response,
    /// and re-initializes `paymentActionsClient`. Pay is disabled while a fetch is in flight.
    ///
    /// Since these values come back from the server rather than being requested by the client,
    /// exercising all four confirmationMethod × captureMethod combinations means tapping
    /// "Get New Payment Action" until each combination has been observed — there's no client-side
    /// control over which one comes back on a given fetch.
    @objc private func fetchClientToken() {
        payButton.isEnabled = false
        progressBlock("Fetching Payment Action client token...")
        
        // TODO: Add fetchPaymentActionClientToken(completion:) to BraintreeDemoMerchantAPIClient.
        // Should hit the sample-merchant server's Payment Action client token endpoint and return
        // the client token plus the confirmationMethod/captureMethod it came back with.
        BraintreeDemoMerchantAPIClient.shared.createCustomerAndFetchClientToken { [weak self] response, error in
            guard let self else { return }
            
            if let error {
                self.progressBlock(error.localizedDescription)
                return
            }
            
            guard let response else {
                self.progressBlock("No client token returned.")
                return
            }
            
            // TODO: Set this label with the appropriate confirm and capture methods when they are available.
            // self.paymentActionConfigLabel.text = "confirmationMethod: \(response.confirmationMethod) · captureMethod: \(response.captureMethod)"
            self.paymentActionsClient = BTPaymentActionsClient(authorization: authorization)
            self.payButton.isEnabled = true
            self.progressBlock("Ready to pay.")
        }
    }
    
    @objc func tappedRefresh() {
        fetchClientToken()
    }
    
    // MARK: - Actions
    
    @objc func tappedPay() {
        progressBlock("Submitting payment method for Payment Action...")
        
        let cardNumber = cardFormView.cardNumber ?? ""
        let expirationMonth = cardFormView.expirationMonth ?? ""
        let expirationYear = cardFormView.expirationYear ?? ""
        
        guard let cvv = cardFormView.cvv else {
            progressBlock("Fill in all the card fields.")
            return
        }
        
        let request = BTCreditCard(
            cardNumber: cardNumber,
            expirationMonth: expirationMonth,
            expirationYear: expirationYear,
            cvv: cvv,
            postalCode: cardFormView.postalCode
        )
        
        setFieldsEnabled(false)
        
        Task { @MainActor in
            do {
                let result = try await paymentActionsClient.submitForPaymentAction(request)
                setFieldsEnabled(true)
                try await handle(result)
            } catch {
                setFieldsEnabled(true)
                progressBlock(error.localizedDescription)
            }
        }
    }
    
    @objc func tappedAutofill() {
        cardFormView.cardNumberTextField.text = "4111111111111111"
        cardFormView.cvvTextField.text = "123"
        cardFormView.expirationTextField.text = CardHelpers.generateFuture(.date)
        cardFormView.postalCodeTextField.text = "94105"
    }
    
    // MARK: - Result Handling
    
    /// Branches on `result.type`, and on `result.serverAction` when a server-driven step is required.
    private func handle(_ result: BTPaymentActionResult) async throws {
        switch result.type {
        case .completed:
            showOrderConfirmation(paymentActionId: result.id)
            
        case .serverActionRequired:
            switch result.serverAction {
            case .confirm:
                progressBlock("Notifying server to confirm Payment Action \(result.id)...")
                try await notifyServerToConfirm(paymentActionId: result.id)
                showOrderConfirmation(paymentActionId: result.id)
            case .capture:
                // Authorized; capture is pending server-side.
                showOrderConfirmation(paymentActionId: result.id)
            case nil:
                progressBlock("Server action required but none was specified.")
            case .some(_):
                progressBlock("Server action unknown.")
            }
            
        case .paymentMethodRequired:
            clearCardFields()
            showDeclineMessage()
            
        case .customerActionRequired, .processing, .canceled, .expired, .unknown:
            progressBlock("Payment Action \(result.id): \(result.type)")
        @unknown default:
            progressBlock("Payment Action \(result.id) case not handled.")
        }
    }
    
    private func showOrderConfirmation(paymentActionId: String) {
        progressBlock("Payment Action \(paymentActionId) complete ✅")
    }
    
    private func showDeclineMessage() {
        progressBlock("Payment method declined. Please try another card.")
    }
    
    /// Asks the merchant server to confirm a Payment Action that requires it.
    private func notifyServerToConfirm(paymentActionId: String) async throws {
        // TODO: Add confirmPaymentAction(id:) to BraintreeDemoMerchantAPIClient.
        // Should hit the sample-merchant server's confirm endpoint for the given Payment Action id. Contract still pending.
        // try await BraintreeDemoMerchantAPIClient.shared.confirmPaymentAction(id: paymentActionId)
    }
    
    // MARK: - UI Helpers
    
    private func setFieldsEnabled(_ isEnabled: Bool) {
        cardFormView.cardNumberTextField.isEnabled = isEnabled
        cardFormView.expirationTextField.isEnabled = isEnabled
        cardFormView.cvvTextField.isEnabled = isEnabled
        cardFormView.postalCodeTextField.isEnabled = isEnabled
        autofillButton.isEnabled = isEnabled
    }
    
    private func clearCardFields() {
        cardFormView.cardNumberTextField.text = nil
        cardFormView.cvvTextField.text = nil
    }
    
    private func createSubviews() {
        cardFormView.translatesAutoresizingMaskIntoConstraints = false
        cardFormView.hidePhoneNumberField = true
        setFieldsEnabled(true)
        
        autofillButton = createButton(title: "Autofill", action: #selector(tappedAutofill))
        
        view.addSubview(cardFormView)
        view.addSubview(autofillButton)
    }
    
    private func layoutConstraints() {
        NSLayoutConstraint.activate([
            cardFormView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            cardFormView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            cardFormView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            cardFormView.heightAnchor.constraint(equalToConstant: 240),
            
            autofillButton.topAnchor.constraint(equalTo: cardFormView.bottomAnchor, constant: 10),
            autofillButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            autofillButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
}
