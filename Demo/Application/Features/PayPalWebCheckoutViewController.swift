import Foundation
import UIKit
import BraintreePayPal
import BraintreeCore

class PayPalWebCheckoutViewController: PaymentButtonBaseViewController {

    lazy var payPalClient = BTPayPalClient(apiClient: apiClient)
    
    lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "placeholder@email.com"
        textField.backgroundColor = .systemBackground
        return textField
    }()

    // TODO: remove UILabel before merging into main DTBTSDK-3766
    let baTokenLabel = UILabel()

    override func createPaymentButton() -> UIView {
        let payPalCheckoutButton = createButton(title: "PayPal Checkout", action: #selector(tappedPayPalCheckout))
        let payPalVaultButton = createButton(title: "PayPal Vault", action: #selector(tappedPayPalVault))
        let payPalPayLaterButton = createButton(title: "PayPal with Pay Later Offered", action: #selector(tappedPayPalPayLater))
        let payPalAppSwitchButton = createButton(title: "PayPal App Switch", action: #selector(tappedPayPalAppSwitchFlow))

        // TODO: remove tapGesture before merging into main DTBTSDK-3766
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        baTokenLabel.isUserInteractionEnabled = true
        baTokenLabel.addGestureRecognizer(tapGesture)
        baTokenLabel.textColor = .systemPink

        let stackView = UIStackView(arrangedSubviews: [
            buttonsStackView(label: "1-Time Checkout Flows", views: [payPalCheckoutButton, payPalPayLaterButton]),
            buttonsStackView(label: "Vault Flows",views: [emailTextField, payPalVaultButton, payPalAppSwitchButton])
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
        let lineItem = BTPayPalLineItem(quantity: "1", unitAmount: "5.00", name: "item one 1234567", kind: .debit)
        lineItem.upcCode = "123456789"
        lineItem.upcType = .UPC_A
        lineItem.imageURL = URL(string: "https://www.example.com/example.jpg")
        request.lineItems = [lineItem]

        payPalClient.tokenize(request) { nonce, error in
            sender.isEnabled = true

            guard let nonce else {
                self.progressBlock(error?.localizedDescription)
                return
            }

            self.completionBlock(nonce)
        }
    }
    
    @objc func tappedPayPalPayLater(_ sender: UIButton) {
        progressBlock("Tapped PayPal - initiating with Pay Later offered")
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false

        let request = BTPayPalCheckoutRequest(amount: "4.30")
        request.offerPayLater = true

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

    @objc func tappedPayPalAppSwitchFlow(_ sender: UIButton) {
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false
        
        guard let userEmail = emailTextField.text, !userEmail.isEmpty else {
            self.progressBlock("Email cannot be nil for App Switch flow")
            return
        }
        
        let payPalClient = BTPayPalClient(apiClient: BTAPIClient(authorization: "sandbox_jy4fvpfg_v7x2rb226dx4pr7b")!)
        let request = BTPayPalVaultRequest(
            userAuthenticationEmail: userEmail,
            enablePayPalAppSwitch: true,
            universalLink: URL(string: "https://braintree-ios-demo.fly.dev/braintree-payments")!
        )

        // TODO: remove NotificationCenter before merging into main DTBTSDK-3766
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receivedNotification),
            name: Notification.Name("BAToken"),
            object: nil
        )

        payPalClient.tokenize(request) { nonce, error in
            sender.isEnabled = true

            guard let nonce else {
                self.progressBlock(error?.localizedDescription)
                return
            }

            self.nonceCompletionBlock(nonce)
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
        buttonsStackView.layoutMargins = .init(top: 5, left: 5, bottom: 5, right: 5)
        buttonsStackView.isLayoutMarginsRelativeArrangement = true
        
        return buttonsStackView
    }

    // TODO: remove labelTapped and receivedNotification before merging into main DTBTSDK-3766

    @objc func labelTapped(sender: UITapGestureRecognizer) {
        UIPasteboard.general.string = baTokenLabel.text
    }

    @objc func receivedNotification(_ notification: Notification) {
        guard let baToken = notification.object else {
            baTokenLabel.text = "No token returned"
            return
        }

        baTokenLabel.text = "\(baToken)"
    }
}
