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
        progressBlock("Tapped PayPal - Checkout using BTPayPalClient")
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false
        
        let client = BTPayPalClient(apiClient: apiClient)
        let request = BTPayPalCheckoutRequest(amount: "4.30")
        
        client.tokenize(request) { nonce, error in
            sender.isEnabled = true
            
            guard let nonce = nonce else {
                self.progressBlock(error?.localizedDescription)
                return
            }
            self.completionBlock(nonce)
        }
    }
}
