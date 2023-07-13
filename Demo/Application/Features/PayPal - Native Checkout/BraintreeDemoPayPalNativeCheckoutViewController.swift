import Foundation
import UIKit
import BraintreePayPalNativeCheckout

class BraintreeDemoPayPalNativeCheckoutViewController: BraintreeDemoPaymentButtonBaseViewController {
    lazy var payPalNativeCheckoutClient = BTPayPalNativeCheckoutClient(apiClient: apiClient)

    func checkoutPaymentButton(title: String) -> UIButton {
      let button = UIButton(type: .system)
      button.setTitle(title, for: .normal)
      button.setTitleColor(.blue, for: .normal)
      button.setTitleColor(.lightGray, for: .highlighted)
      button.setTitleColor(.lightGray, for: .disabled)
      button.translatesAutoresizingMaskIntoConstraints = false
      return button
    }

    override func createPaymentButton() -> UIView! {
        let payPalCheckoutButton = checkoutPaymentButton(title: "One Time Checkout")
        payPalCheckoutButton.addTarget(self, action: #selector(tappedPayPalCheckout), for: .touchUpInside)

        let payPalBAWithoutPurchase = checkoutPaymentButton(title: "Billing Agreements Without Purchase Checkout")
        payPalBAWithoutPurchase.addTarget(self, action: #selector(tappedPayPalVault), for: .touchUpInside)

        let payPalBAWithPurchase = checkoutPaymentButton(title: "Billing Agreements With Purchase Checkout")
        payPalBAWithPurchase.addTarget(self, action: #selector(tappedBAWithPurchase), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [payPalCheckoutButton, payPalBAWithoutPurchase, payPalBAWithPurchase])
        stackView.axis = .vertical
        stackView.alignment = .center
      stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [
                payPalCheckoutButton.topAnchor.constraint(equalTo: stackView.topAnchor),
                payPalCheckoutButton.heightAnchor.constraint(equalToConstant: 19.5),

                payPalBAWithoutPurchase.topAnchor.constraint(equalTo: payPalCheckoutButton.bottomAnchor, constant: 20),
                payPalBAWithoutPurchase.heightAnchor.constraint(equalToConstant: 19.5),

                payPalBAWithPurchase.topAnchor.constraint(equalTo: payPalBAWithoutPurchase.bottomAnchor, constant: 20),
                payPalBAWithPurchase.heightAnchor.constraint(equalToConstant: 19.5)
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

        @objc func tappedBAWithPurchase(_ sender: UIButton) {
            progressBlock("Tapped PayPal - BA With Purchase using BTPayPalNativeCheckout")
            sender.setTitle("Processing...", for: .disabled)
            sender.isEnabled = false
            
            let request =  BTPayPalNativeCheckoutRequest(amount: "4.30", requestBillingAgreement: true)
            
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
