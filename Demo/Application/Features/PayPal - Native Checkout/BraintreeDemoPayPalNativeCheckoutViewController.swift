import Foundation
import UIKit
import BraintreePayPalNativeCheckout

class BraintreeDemoPayPalNativeCheckoutViewController: BraintreeDemoPaymentButtonBaseViewController {
    lazy var payPalNativeCheckoutClient = BTPayPalNativeCheckoutClient(apiClient: apiClient)

    override func createPaymentButton() -> UIView! {
        let payPalCheckoutButton = UIButton(type: .system)
        payPalCheckoutButton.setTitle("One Time Checkout", for: .normal)
        payPalCheckoutButton.setTitleColor(.blue, for: .normal)
        payPalCheckoutButton.setTitleColor(.lightGray, for: .highlighted)
        payPalCheckoutButton.setTitleColor(.lightGray, for: .disabled)
        payPalCheckoutButton.addTarget(self, action: #selector(tappedPayPalCheckout), for: .touchUpInside)
        payPalCheckoutButton.translatesAutoresizingMaskIntoConstraints = false

        let payPalVaultButton = UIButton(type: .system)
        payPalVaultButton.setTitle("Vault Checkout", for: .normal)
        payPalVaultButton.setTitleColor(.blue, for: .normal)
        payPalVaultButton.setTitleColor(.lightGray, for: .highlighted)
        payPalVaultButton.setTitleColor(.lightGray, for: .disabled)
        payPalVaultButton.addTarget(self, action: #selector(tappedPayPalVault), for: .touchUpInside)
        payPalVaultButton.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [payPalCheckoutButton, payPalVaultButton])
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [
                payPalCheckoutButton.topAnchor.constraint(equalTo: stackView.topAnchor),
                payPalCheckoutButton.heightAnchor.constraint(equalToConstant: 19.5),

                payPalVaultButton.topAnchor.constraint(equalTo: payPalCheckoutButton.bottomAnchor, constant: 5),
                payPalVaultButton.heightAnchor.constraint(equalToConstant: 19.5)
            ]
        )

        return stackView
    }
    
    @objc func tappedPayPalCheckout(_ sender: UIButton) {
        progressBlock("Tapped PayPal - Native Checkout using BTPayPalNativeCheckout")
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false
                
        let request = BTPayPalNativeCheckoutRequest(amount: "4.30")
        payPalNativeCheckoutClient.tokenize(request) { nonce, error in
            sender.isEnabled = true
            
            guard let nonce = nonce else {
                self.progressBlock(error?.localizedDescription)
                return
            }
            self.completionBlock(nonce)
        }
    }

    @objc func tappedPayPalVault(_ sender: UIButton) {
        progressBlock("Tapped PayPal - Vault using BTPayPalNativeCheckout")
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false

        let request = BTPayPalNativeVaultRequest()

        payPalNativeCheckoutClient.tokenize(request) { nonce, error in
            sender.isEnabled = true

            guard let nonce = nonce else {
                self.progressBlock(error?.localizedDescription)
                return
            }
            self.completionBlock(nonce)
        }
    }
}
