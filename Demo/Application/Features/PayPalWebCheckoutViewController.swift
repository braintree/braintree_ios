import Foundation
import UIKit
import BraintreePayPal

class PayPalWebCheckoutViewController: PaymentButtonBaseViewController {

    lazy var payPalClient = BTPayPalClient(apiClient: apiClient)
    
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

    override func createPaymentButton() -> UIView {
        let payPalCheckoutButton = createButton(title: "PayPal Checkout", action: #selector(tappedPayPalCheckout))
        let payPalVaultButton = createButton(title: "PayPal Vault", action: #selector(tappedPayPalVault))

        let stackView = UIStackView(arrangedSubviews: [
            UIStackView(arrangedSubviews: [emailLabel, emailTextField]),
            buttonsStackView(label: "1-Time Checkout", views: [
                UIStackView(arrangedSubviews: [payLaterToggleLabel, payLaterToggle]),
                UIStackView(arrangedSubviews: [newPayPalCheckoutToggleLabel, newPayPalCheckoutToggle]),
                payPalCheckoutButton
            ]),
            buttonsStackView(label: "Vault",views: [payPalVaultButton])
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
    
    // MARK: - Helpers
    
    private func buttonsStackView(label: String, views: [UIView]) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = label
        titleLabel.font = .preferredFont(forTextStyle: .title3)
        
        let buttonsStackView = UIStackView(arrangedSubviews: [titleLabel] + views)
        buttonsStackView.axis = .vertical
        buttonsStackView.distribution = .fillProportionally
        buttonsStackView.backgroundColor = .systemGray6
        buttonsStackView.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        buttonsStackView.isLayoutMarginsRelativeArrangement = true
        
        return buttonsStackView
    }
}
