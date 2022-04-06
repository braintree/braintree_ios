import UIKit
import BraintreePayPal

class BraintreeDemoPayPalPayLaterViewController: BraintreeDemoPaymentButtonBaseViewController {
    
    override func createPaymentButton() -> UIView! {
        lazy var payPalPayLaterButton: UIButton = {
            let payPalPayLaterButton = UIButton(type: .system)
            payPalPayLaterButton.setTitle("PayPal with Pay Later Offered", for: .normal)
            payPalPayLaterButton.setTitleColor(.blue, for: .normal)
            payPalPayLaterButton.setTitleColor(.lightGray, for: .highlighted)
            payPalPayLaterButton.setTitleColor(.lightGray, for: .disabled)
            payPalPayLaterButton.addTarget(self, action: #selector(tappedPayPalPayLater), for: .touchUpInside)
            return payPalPayLaterButton
        }()
        
        return payPalPayLaterButton
    }
    
    @objc func tappedPayPalPayLater(_ sender: UIButton) {
        progressBlock("Tapped PayPal - initiating with Pay Later offered")
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false
        
        let driver = BTPayPalDriver(apiClient: apiClient)
        let request = BTPayPalCheckoutRequest(amount: "4.30")
        request.offerPayLater = true
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
