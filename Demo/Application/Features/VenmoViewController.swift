import UIKit
import BraintreeVenmo

class VenmoViewController: PaymentButtonBaseViewController {

    // swiftlint:disable:next implicitly_unwrapped_optional
    var venmoClient: BTVenmoClient!

    let vaultToggle = Toggle(title: "Vault")

    override func viewDidLoad() {
        super.heightConstraint = 150
        super.viewDidLoad()
        venmoClient = BTVenmoClient(
            authorization: DemoConstants.sandboxTokenizationKey,
            // swiftlint:disable:next force_unwrapping
            universalLink: URL(string: "https://mobile-sdk-demo-site-838cead5d3ab.herokuapp.com/braintree-payments")!
        )

        title = "Custom Venmo Button"
    }
    
    override func createPaymentButton() -> UIView {
        let venmoButton = createButton(title: "Venmo", action: #selector(tappedVenmo))

        let venmoStackView = buttonsStackView(label: "Venmo Payment Flow", views: [
            vaultToggle,
            venmoButton
        ])

        venmoStackView.spacing = 12
        venmoStackView.translatesAutoresizingMaskIntoConstraints = false

        return venmoStackView
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
