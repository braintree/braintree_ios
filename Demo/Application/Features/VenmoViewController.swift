import UIKit
import BraintreeVenmo

class VenmoViewController: PaymentButtonBaseViewController {
 
    // swiftlint:disable:next implicitly_unwrapped_optional
    var venmoClient: BTVenmoClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        venmoClient = BTVenmoClient(apiClient: apiClient)
        title = "Custom Venmo Button"
    }
    
    override func createPaymentButton() -> UIView {
        let venmoButton = createButton(title: "Venmo", action: #selector(tappedVenmo))
        let venmoECDButton = createButton(title: "Venmo (with ECD options)", action: #selector(tappedVenmoWithECD))
        let venmoUniversalLinkButton = createButton(title: "Venmo Universal Links", action: #selector(tappedVenmoWithUniversalLinks))

        let stackView = UIStackView(arrangedSubviews: [venmoButton, venmoECDButton, venmoUniversalLinkButton])
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

    @objc func tappedVenmoWithUniversalLinks() {
        self.progressBlock("Tapped Venmo Universal Links - initiating Venmo auth")

        let venmoRequest = BTVenmoRequest(paymentMethodUsage: .multiUse)
        venmoRequest.vault = true
        venmoRequest.fallbackToWeb = true

        checkout(request: venmoRequest)
    }

    func checkout(request: BTVenmoRequest) {
        Task {
            do {
                let venmoAccount = try await venmoClient.tokenize(request)
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
