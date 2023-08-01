import UIKit
import BraintreeVenmo

class BraintreeDemoVenmoViewController: BraintreeDemoPaymentButtonBaseViewController {
    
    var venmoClient: BTVenmoClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.venmoClient = BTVenmoClient(apiClient: self.apiClient)
        self.title = "Custom Venmo Button"
    }
    
    override func createPaymentButton() -> UIView! {
        let button = UIButton(type: .custom)
        button.setTitle("Venmo (custom button)", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.addTarget(self, action: #selector(tappedCustomVenmo), for: .touchUpInside)
        return button
    }
    
    @objc func tappedCustomVenmo() {
        self.progressBlock("Tapped Venmo - initiating Venmo auth")
        
        let venmoRequest = BTVenmoRequest(paymentMethodUsage: .multiUse)
        venmoRequest.vault = true
        venmoRequest.collectCustomerBillingAddress = true
        venmoRequest.collectCustomerShippingAddress = true
        venmoRequest.totalAmount = "30.00"
        venmoRequest.taxAmount = "1.10"
        venmoRequest.discountAmount = "1.10"
        venmoRequest.shippingAmount = "0.00"
        
        let lineItem = BTVenmoLineItem(quantity: 1, unitAmount: "30.00", name: "item-1", kind: .debit)
        lineItem.unitTaxAmount = "1.00"
        venmoRequest.lineItems = [lineItem]
        
        self.venmoClient.tokenize(venmoRequest) { venmoAccount, error in
            if let venmoAccount {
                self.progressBlock("Got a nonce 💎!")
                self.completionBlock(venmoAccount)
            } else if let error {
                self.progressBlock(error.localizedDescription)
            } else {
                self.progressBlock("Canceled 🔰")
            }
        }
    }
    
}
