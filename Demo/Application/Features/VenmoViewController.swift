import UIKit
import BraintreeVenmo

class VenmoViewController: PaymentButtonBaseViewController {
 
    // swiftlint:disable:next implicitly_unwrapped_optional
    var venmoClient: BTVenmoClient!

    let ecdOptionsToggle = ToggleWithLabel("Add ECD Options")
    let webFallbackToggle = ToggleWithLabel("Enable Web Fallback")
    let vaultToggle = ToggleWithLabel("Vault")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        venmoClient = BTVenmoClient(apiClient: apiClient)
        title = "Custom Venmo Button"
    }
    
    override func createPaymentButton() -> UIView {
        let venmoButton = createButton(title: "Venmo", action: #selector(tappedVenmo))

        let stackView = UIStackView(arrangedSubviews: [ecdOptionsToggle, webFallbackToggle, vaultToggle, venmoButton])
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }
    
    @objc func tappedVenmo() {
        self.progressBlock("Tapped Venmo - initiating Venmo auth")
        
        let venmoRequest = BTVenmoRequest(paymentMethodUsage: .multiUse)

        if ecdOptionsToggle.isOn {
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
        }
        
        if webFallbackToggle.isOn {
            venmoRequest.fallbackToWeb = true
        }
        
        if vaultToggle.isOn {
            venmoRequest.vault = true
        }
        
        Task {
            do {
                let venmoAccount = try await venmoClient.tokenize(venmoRequest)
                progressBlock("Got a nonce 💎!")
                completionBlock(venmoAccount)
            } catch {
                if error as? BTVenmoError == .canceled {
                    progressBlock("Canceled 🔰")
                } else {
                    progressBlock(error.localizedDescription)
                }
            }
        }
    }
}
