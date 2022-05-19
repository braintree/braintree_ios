import Foundation
import UIKit
import BraintreePayPalNativeCheckout

class BraintreeDemoPayPalNativeCheckoutViewController: BraintreeDemoPaymentButtonBaseViewController {
    private var client: BTPayPalNativeCheckoutClient!
    private var button: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        client = BTPayPalNativeCheckoutClient()
    }
    
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
        progressBlock("Tapped PayPal - Native Checkout using BTPayPalDriver")
        sender.setTitle("Processing...", for: .disabled)
        sender.isEnabled = false

//        client.tokenize()
    }
}
