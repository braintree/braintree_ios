import UIKit
import BraintreeVenmo

// swiftlint:disable implicitly_unwrapped_optional
class VenmoViewController: PaymentButtonBaseViewController {
 
    var venmoClient: BTVenmoClient!
    var venmoClientUniversalLink: BTVenmoClient!
    
    lazy var universalLinkReturnToggleLabel: UILabel = {
        let label = UILabel()
        label.text = "Use Universal Link Return"
        label.font = .preferredFont(forTextStyle: .footnote)
        return label
    }()
    
    let universalLinkReturnToggle = UISwitch()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        venmoClient = BTVenmoClient(apiClient: apiClient)
        venmoClientUniversalLink = BTVenmoClient(
            apiClient: apiClient,
            // swiftlint:disable:next force_unwrapping
            universalLink: URL(string: "https://mobile-sdk-demo-site-838cead5d3ab.herokuapp.com/braintree-payments")!
        )
        title = "Custom Venmo Button"
    }
    
    override func createPaymentButton() -> UIView {
        let venmoButton = createButton(title: "Venmo", action: #selector(tappedVenmo))
        let venmoECDButton = createButton(title: "Venmo (with ECD options)", action: #selector(tappedVenmoWithECD))
        let venmoUniversalLinkButton = createButton(title: "Venmo Universal Links", action: #selector(tappedVenmoWithUniversalLinks))

        let stackView = UIStackView(
            arrangedSubviews: [
                UIStackView(arrangedSubviews: [universalLinkReturnToggleLabel, universalLinkReturnToggle]),
                venmoButton,
                venmoECDButton,
                venmoUniversalLinkButton
            ]
        )
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
                let venmoAccount = try await (universalLinkReturnToggle.isOn ? venmoClientUniversalLink : venmoClient).tokenize(request)
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
