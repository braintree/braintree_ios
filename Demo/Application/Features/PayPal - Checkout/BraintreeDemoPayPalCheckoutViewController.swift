import UIKit
import BraintreePayPal

class BraintreeDemoPayPalCheckoutViewController: BraintreeDemoPaymentButtonBaseViewController {
    
    override func createPaymentButton() -> UIView! {
        lazy var payPalCheckoutButton: UIButton = {
            let payPalCheckoutButton = UIButton(type: .system)
            payPalCheckoutButton.setTitle("PayPal Checkout", for: .normal)
            payPalCheckoutButton.setTitleColor(.blue, for: .normal)
            payPalCheckoutButton.setTitleColor(.lightGray, for: .highlighted)
            payPalCheckoutButton.setTitleColor(.lightGray, for: .disabled)
            payPalCheckoutButton.addTarget(self, action: #selector(tappedPayPalCheckout), for: .touchUpInside)
            return payPalCheckoutButton
        }()
        
        return payPalCheckoutButton
    }
    
    @objc func tappedPayPalCheckout(_ sender: UIButton) {
        progressBlock("Tapped PayPal - Checkout using BTPayPalDriver")
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false
        
        let driver = BTPayPalDriver(apiClient: apiClient)
        let request = BTPayPalCheckoutRequest(amount: "4.30")
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
