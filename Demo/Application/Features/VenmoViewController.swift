import UIKit
import BraintreeVenmo

class VenmoViewController: PaymentButtonBaseViewController {

    // swiftlint:disable:next implicitly_unwrapped_optional
    var venmoClient: BTVenmoClient!

    let webFallbackToggle = Toggle(title: "Enable Web Fallback")
    let vaultToggle = Toggle(title: "Vault")
    let universalLinkReturnToggle = Toggle(title: "Use Universal Link Return")

    override func viewDidLoad() {
        super.heightConstraint = 150
        super.viewDidLoad()
        venmoClient = BTVenmoClient(apiClient: apiClient)
        title = "Custom Venmo Button"
    }
    
    override func createPaymentButton() -> UIView {
        let venmoButton = createButton(title: "Venmo", action: #selector(tappedVenmo))

        let stackView = UIStackView(arrangedSubviews: [webFallbackToggle, vaultToggle, universalLinkReturnToggle, venmoButton])
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
        
        if webFallbackToggle.isOn {
            venmoRequest.fallbackToWeb = true
        }
        
        if vaultToggle.isOn {
            venmoRequest.vault = true
        }

        if universalLinkReturnToggle.isOn {
            venmoClient = BTVenmoClient(
                apiClient: apiClient,
                // swiftlint:disable:next force_unwrapping
                universalLink: URL(string: "https://mobile-sdk-demo-site-838cead5d3ab.herokuapp.com/braintree-payments")!
            )
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
