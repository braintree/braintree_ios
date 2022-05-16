import Foundation
import UIKit
import BraintreePayPalNativeCheckout

class BraintreeDemoPayPalNativeCheckoutViewController: BraintreeDemoPaymentButtonBaseViewController {
    
    override func createPaymentButton() -> UIView! {
        lazy var payPalCheckoutButton: UIButton = {
            let payPalCheckoutButton = UIButton(type: .system)
            payPalCheckoutButton.setTitle("PayPal Native Checkout", for: .normal)
            payPalCheckoutButton.setTitleColor(.blue, for: .normal)
            payPalCheckoutButton.setTitleColor(.lightGray, for: .highlighted)
            payPalCheckoutButton.setTitleColor(.lightGray, for: .disabled)
            payPalCheckoutButton.addTarget(self, action: #selector(tappedPayPalCheckout), for: .touchUpInside)
            return payPalCheckoutButton
        }()
        
        return payPalCheckoutButton
    }
    
    
    @objc func tappedPayPalCheckout(_ sender: UIButton) {
        progressBlock("Tapped PayPal - Native Checkout using BTPayPalDriver")
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false

        let client = BTPayPalNativeCheckoutClient(clientID: "AVgzJ5j6adTAjZHTRHCgzKdWXwOxaCcUc9tZWsdNWVe9WwNasAKWHbiuluX8nVBksz0hV9psUMGLQuWW",
                                                  returnUrl: "com.braintreepayments.Demo://paypalpay")
//        let driver = BTPayPalDriver(apiClient: apiClient)
//        let request = BTPayPalCheckoutRequest(amount: "4.30")
//        request.activeWindow = self.view.window
//
//        driver.tokenizePayPalAccount(with: request) { nonce, error in
//            sender.isEnabled = true
//
//            guard let nonce = nonce else {
//                self.progressBlock(error?.localizedDescription)
//                return
//            }
//            self.completionBlock(nonce)
//        }
    }
}
