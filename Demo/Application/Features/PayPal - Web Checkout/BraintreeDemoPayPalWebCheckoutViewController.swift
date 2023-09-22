import Foundation
import UIKit
import BraintreePayPal

class BraintreeDemoPayPalWebCheckoutViewController: BraintreeDemoPaymentButtonBaseViewController {

    lazy var payPalClient = BTPayPalClient(apiClient: apiClient)

    override func createPaymentButton() -> UIView! {
        let payPalCheckoutButton = paymentButton(title: "PayPal Checkout", action: #selector(tappedPayPalCheckout))
        let payPalVaultButton = paymentButton(title: "PayPal Vault", action: #selector(tappedPayPalVault))
        let payPalPayLaterButton = paymentButton(title: "PayPal with Pay Later Offered", action: #selector(tappedPayPalPayLater))

        let buttons = [payPalCheckoutButton, payPalVaultButton, payPalPayLaterButton]
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }

    @objc func tappedPayPalCheckout(_ sender: UIButton) {
        progressBlock("Tapped PayPal - Checkout using BTPayPalClient")
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false

        let request = BTPayPalCheckoutRequest(amount: "4.30")

        payPalClient.tokenize(request) { nonce, error in
            sender.isEnabled = true

            guard let nonce else {
                self.progressBlock(error?.localizedDescription)
                return
            }

            self.completionBlock(nonce)
        }
    }

    @objc func tappedPayPalVault(_ sender: UIButton) {
        progressBlock("Tapped PayPal - Vault using BTPayPalClient")
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false

        let request = BTPayPalVaultRequest()

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

    // TODO: move into a shared class once the base ViewControllers are converted to Swift
    func paymentButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.setTitleColor(.lightGray, for: .highlighted)
        button.setTitleColor(.lightGray, for: .disabled)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
}
