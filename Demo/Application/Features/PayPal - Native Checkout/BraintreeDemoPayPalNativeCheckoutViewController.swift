import Foundation
import UIKit
import BraintreePayPalNativeCheckout

class BraintreeDemoPayPalNativeCheckoutViewController: BraintreeDemoPaymentButtonBaseViewController {
    lazy var payPalNativeCheckoutClient = BTPayPalNativeCheckoutClient(apiClient: apiClient)

    override func createPaymentButton() -> UIView! {
        let payPalCheckoutButton = UIButton(type: .system)
        payPalCheckoutButton.setTitle("PayPal Native Checkout", for: .normal)
        payPalCheckoutButton.setTitleColor(.blue, for: .normal)
        payPalCheckoutButton.setTitleColor(.lightGray, for: .highlighted)
        payPalCheckoutButton.setTitleColor(.lightGray, for: .disabled)
        payPalCheckoutButton.addTarget(self, action: #selector(tappedPayPalCheckout), for: .touchUpInside)
        return payPalCheckoutButton
    }
    
    @objc func tappedPayPalCheckout(_ sender: UIButton) {
        progressBlock("Tapped PayPal - Native Checkout using BTPayPalNativeCheckout")
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false
                
        let request = BTPayPalNativeCheckoutRequest(amount: "4.30")
        payPalNativeCheckoutClient.tokenizePayPalAccount(with: request) { nonce, error in
            sender.isEnabled = true
            
            guard let nonce = nonce else {
                self.progressBlock(error?.localizedDescription)
                return
            }
            self.nonceStringCompletionBlock(nonce.nonce)
        }
    }

    @objc func tappedPayPalVault(_ sender: UIButton) {
        progressBlock("Tapped PayPal - Vault using BTPayPalNativeCheckout")
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false

        let driver = BTPayPalDriver(apiClient: apiClient)
        let request = BTPayPalVaultRequest()
        request.activeWindow = self.view.window

        driver.tokenizePayPalAccount(with: request) { nonce, error in
            sender.isEnabled = true

            guard let nonce = nonce else {
                self.progressBlock(error?.localizedDescription)
                return
            }
            self.completionBlock(nonce)
        }
    }
}
