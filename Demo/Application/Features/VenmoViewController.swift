import UIKit
import BraintreeVenmo

class VenmoViewController: PaymentButtonBaseViewController {
    
    var venmoClient: BTVenmoClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        venmoClient = BTVenmoClient(apiClient: apiClient)
        title = "Custom Venmo Button"
    }
    
    override func createPaymentButton() -> UIView {
        let venmoButton = createButton(title: "Venmo", action: #selector(tappedVenmo))
        let venmoECDButton = createButton(title: "Venmo (with ECD options)", action: #selector(tappedVenmoWithECD))
        venmoECDButton.setTitle("Venmo (with ECD options)", for: .normal)
        venmoECDButton.setTitleColor(.blue, for: .normal)
        venmoECDButton.setTitleColor(.lightGray, for: .highlighted)
        venmoECDButton.setTitleColor(.lightGray, for: .disabled)
        venmoECDButton.addTarget(self, action: #selector(tappedVenmoWithECD), for: .touchUpInside)
        venmoECDButton.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [venmoButton, venmoECDButton])
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }
    
    @objc func tappedVenmo() {
        self.progressBlock("Tapped Venmo - initiating Venmo auth")
        
        let venmoRequest = BTVenmoRequest(paymentMethodUsage: .multiUse)
        venmoRequest.vault = true
        
        checkout(request: venmoRequest)
    }
    
    @objc func tappedVenmoWithECD() {
        self.progressBlock("Tapped Venmo ECD - initiating Venmo auth")
        
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
        
        checkout(request: venmoRequest)
    }
    
    func checkout(request: BTVenmoRequest)  {
        Task {
            do {
                let venmoAccount = try await venmoClient.tokenize(request)
                progressBlock("Got a nonce 💎!")
                completionBlock(venmoAccount)
            } catch {
                if (error as NSError).code == 10 {
                    progressBlock("Canceled 🔰")
                } else {
                    progressBlock(error.localizedDescription)
                }
            }
        }
    }
}
