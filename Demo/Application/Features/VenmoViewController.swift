import UIKit
import BraintreeVenmo

class VenmoViewController: PaymentButtonBaseViewController {
 
    // swiftlint:disable:next implicitly_unwrapped_optional
    var venmoClient: BTVenmoClient!

    let vaultToggle = Toggle(title: "Vault")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        venmoClient = BTVenmoClient(apiClient: apiClient)
        title = "Custom Venmo Button"
    }
    
    override func createPaymentButton() -> UIView {
        let venmoButton = createButton(title: "Venmo", action: #selector(tappedVenmo))

        let stackView = UIStackView(arrangedSubviews: [vaultToggle, venmoButton])
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }
    
    @objc func tappedVenmo() {
        self.progressBlock("Tapped Venmo - initiating Venmo auth")
        
        let isVaultingEnabled = vaultToggle.isOn
        let venmoRequest = BTVenmoRequest(
            paymentMethodUsage: .multiUse,
            vault: isVaultingEnabled
        )

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
