import Foundation
import UIKit
import BraintreePayPal
import BraintreeCore

class PayPalWebCheckoutViewController: PaymentButtonBaseViewController {

    lazy var payPalClient = BTPayPalClient(
        apiClient: apiClient,
        universalLink: URL(string: "https://mobile-sdk-demo-site-838cead5d3ab.herokuapp.com/braintree-payments")!
    )
    
    lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Buyer email:"
        return label
    }()
    
    lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "placeholder@email.com"
        textField.backgroundColor = .systemBackground
        return textField
    }()
    
    lazy var payLaterToggleLabel: UILabel = {
        let label = UILabel()
        label.text = "Offer Pay Later"
        label.font = .preferredFont(forTextStyle: .footnote)
        return label
    }()
    
    let payLaterToggle = UISwitch()

    lazy var newPayPalCheckoutToggleLabel: UILabel = {
        let label = UILabel()
        label.text = "New PayPal Checkout Experience"
        label.font = .preferredFont(forTextStyle: .footnote)
        return label
    }()
    
    let newPayPalCheckoutToggle = UISwitch()

    override func viewDidLoad() {
        super.heightConstraint = 300
        super.viewDidLoad()
    }

    override func createPaymentButton() -> UIView {
        let payPalCheckoutButton = createButton(title: "PayPal Checkout", action: #selector(tappedPayPalCheckout))
        let payPalVaultButton = createButton(title: "PayPal Vault", action: #selector(tappedPayPalVault))
        let payPalEditVaultButton = createButton(title: "Edit FI", action: #selector(tappedPayPalEditVault))
        let payPalEditVaultErrorHandlingButton = createButton(title: "Edit FI (Error Handling)", action: #selector(tappedPayPalEditVaultErrorHandling))
        let payPalAppSwitchButton = createButton(title: "PayPal App Switch", action: #selector(tappedPayPalAppSwitch))
        let oneTimeCheckoutStackView = buttonsStackView(label: "1-Time Checkout", views: [
            UIStackView(arrangedSubviews: [payLaterToggleLabel, payLaterToggle]),
            UIStackView(arrangedSubviews: [newPayPalCheckoutToggleLabel, newPayPalCheckoutToggle]),
            payPalCheckoutButton
        ])
        let vaultStackView = buttonsStackView(label: "Vault",views: [payPalVaultButton, payPalAppSwitchButton, payPalEditVaultButton, payPalEditVaultErrorHandlingButton])


        let stackView = UIStackView(arrangedSubviews: [
            UIStackView(arrangedSubviews: [emailLabel, emailTextField]),
            oneTimeCheckoutStackView,
            vaultStackView
        ])

        NSLayoutConstraint.activate([
            oneTimeCheckoutStackView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            oneTimeCheckoutStackView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),

            vaultStackView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            vaultStackView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
          ])

        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 25
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    // MARK: - 1-Time Checkout Flows

    @objc func tappedPayPalCheckout(_ sender: UIButton) {
        progressBlock("Tapped PayPal - Checkout using BTPayPalClient")
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false

        let request = BTPayPalCheckoutRequest(amount: "5.00")
        request.userAuthenticationEmail = emailTextField.text
        
        let lineItem = BTPayPalLineItem(quantity: "1", unitAmount: "5.00", name: "item one 1234567", kind: .debit)
        lineItem.upcCode = "123456789"
        lineItem.upcType = .UPC_A
        lineItem.imageURL = URL(string: "https://www.example.com/example.jpg")

        request.lineItems = [lineItem]        
        request.offerPayLater = payLaterToggle.isOn
        request.intent = newPayPalCheckoutToggle.isOn ? .sale : .authorize

        payPalClient.tokenize(request) { nonce, error in
            sender.isEnabled = true

            guard let nonce else {
                self.progressBlock(error?.localizedDescription)
                return
            }

            self.completionBlock(nonce)
        }
    }
    
    // MARK: - Vault Flows
    
    @objc func tappedPayPalVault(_ sender: UIButton) {
        progressBlock("Tapped PayPal - Vault using BTPayPalClient")
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false

        let request = BTPayPalVaultRequest()
        request.userAuthenticationEmail = emailTextField.text

        payPalClient.tokenize(request) { nonce, error in
            sender.isEnabled = true

            guard let nonce else {
                self.progressBlock(error?.localizedDescription)
                return
            }

            self.completionBlock(nonce)
        }
    }

    @objc func tappedPayPalAppSwitch(_ sender: UIButton) {
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false
        
        guard let userEmail = emailTextField.text, !userEmail.isEmpty else {
            self.progressBlock("Email cannot be nil for App Switch flow")
            sender.isEnabled = true
            return
        }

        let request = BTPayPalVaultRequest(
            userAuthenticationEmail: userEmail,
            enablePayPalAppSwitch: true
        )

        payPalClient.tokenize(request) { nonce, error in
            sender.isEnabled = true
            
            guard let nonce else {
                self.progressBlock(error?.localizedDescription)
                return

            }
            
            self.completionBlock(nonce)
        }
    }

    // MARK: Edit FI flow

    @objc func tappedPayPalEditVault(_ sender: UIButton) {
        progressBlock("Tapped PayPal - Edit FI")
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false

        let request = BTPayPalVaultEditRequest(editPayPalVaultID: "+fZXfUn6nzR+M9661WGnCBfyPlIExIMPY2rS9AC2vmA=")
        payPalClient.edit(request) { editResult, error in
            sender.isEnabled = true

            guard let editResult else {
                self.progressBlock(error?.localizedDescription)
                return
            }

            self.paypalEditCompletionBlock(editResult.riskCorrelationID)
        }
    }


    @objc func tappedPayPalEditVaultErrorHandling(_ sender: UIButton) {
        progressBlock("Tapped PayPal - Edit FI, ErrorHandling")
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false

        // TODO: textField for entry of riskCorrelationID
        let request = BTPayPalVaultErrorHandlingEditRequest(editPayPalVaultID: "+fZXfUn6nzR+M9661WGnCBfyPlIExIMPY2rS9AC2vmA=", riskCorrelationID: "test")

        payPalClient.edit(request) { editResult, error in
            sender.isEnabled = true

            guard let editResult else {
                self.progressBlock(error?.localizedDescription)
                return
            }

            self.paypalEditCompletionBlock(editResult.riskCorrelationID)
        }
    }

    // MARK: - Helpers
    
    private func buttonsStackView(label: String, views: [UIView]) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = label
        
        let buttonsStackView = UIStackView(arrangedSubviews: [titleLabel] + views)
        buttonsStackView.axis = .vertical
        buttonsStackView.distribution = .fillProportionally
        buttonsStackView.backgroundColor = .systemGray6
        buttonsStackView.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        buttonsStackView.isLayoutMarginsRelativeArrangement = true
        
        return buttonsStackView
    }
}
