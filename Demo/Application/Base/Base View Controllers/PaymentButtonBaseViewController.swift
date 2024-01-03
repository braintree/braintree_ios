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
        let lineItem = BTPayPalLineItem(
                    quantity: "1",
                    unitAmount: "5.00",
                    name: "item one 1234567",
                    kind: .credit)
        lineItem.upcCode = "123456789"
        lineItem.upcType = BTPayPalLineItemUpcType.UPC_A
        lineItem.imageUrl = URL(string: "www.braintreee.com/image.xml")
        request.lineItems = [lineItem]
        
        client.tokenize(request) { nonce, error in
            sender.isEnabled = true
            
            guard let nonce = nonce else {
                self.progressBlock(error?.localizedDescription)
                return
            }
            self.nonceStringCompletionBlock(nonce.nonce)
        }
    }
}
