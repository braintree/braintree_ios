import UIKit
import BraintreePayPalNative

class BraintreeDemoPayPalNativeUIViewController: BraintreeDemoBaseViewController {

    private var ppNativeClient: BTPayPalNativeClient?

    override func viewDidLoad() {
        super.viewDidLoad()
        let checkoutButton = UIButton(type: .custom)
        checkoutButton.setTitle(NSLocalizedString("PayPal Checkout (Native UI)", comment: ""), for: .normal)
        checkoutButton.setTitleColor(UIColor.blue, for: .normal)
        checkoutButton.setTitleColor(UIColor(red: 50.0 / 255, green: 50.0 / 255, blue: 255.0 / 255, alpha: 1.0), for: .highlighted)
        checkoutButton.setTitleColor(UIColor.lightGray, for: .disabled)
        checkoutButton.addTarget(self, action: #selector(tappedPayPalCheckout(_:)), for: .touchUpInside)

        let vaultButton = UIButton(type: .custom)
        vaultButton.setTitle(NSLocalizedString("PayPal Vault (Native UI)", comment: ""), for: .normal)
        vaultButton.setTitleColor(UIColor.blue, for: .normal)
        vaultButton.setTitleColor(UIColor(red: 50.0 / 255, green: 50.0 / 255, blue: 255.0 / 255, alpha: 1.0), for: .highlighted)
        vaultButton.setTitleColor(UIColor.lightGray, for: .disabled)
        vaultButton.addTarget(self, action: #selector(tappedPayPalVault(_:)), for: .touchUpInside)

        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 3
        label.text = "This demo is using a hard-coded tokenization key for a BT sandbox with a linked PayPal sandbox account."

        let stackView = UIStackView(arrangedSubviews: [checkoutButton, vaultButton, label])
        stackView.axis = .vertical
        stackView.spacing = 40
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    @objc func tappedPayPalCheckout(_ button: UIButton) {
        self.progressBlock("Tapped PayPal Checkout - Native UI: using BTPayPalNativeClient")
        let request = BTPayPalNativeCheckoutRequest(payPalReturnURL: "tacocats://paypalpay", amount: "10.00")
        tokenizePayPalAccount(button: button, request: request)
    }

    @objc func tappedPayPalVault(_ button: UIButton) {
        self.progressBlock("Tapped PayPal Vault - Native UI: using BTPayPalNativeClient")
        let request = BTPayPalNativeVaultRequest(payPalReturnURL: "tacocats://paypalpay")
        tokenizePayPalAccount(button: button, request: request)
    }

    private func tokenizePayPalAccount(button: UIButton, request: BTPayPalRequest) {
        button.setTitle(NSLocalizedString("Processing...", comment: ""), for: .disabled)
        button.isEnabled = false

        // This demo uses a hard coded tokenization key.
        // You can find the corresponding accounts for "PayPal Native Checkout" in 1Password.
        // TODO: obtain credentials for a BT-PP linked prod account. Update this demo to properly toggle b/w envs.
        guard let apiClient = BTAPIClient(authorization: "sandbox_8hpbq6nh_ks3tvzmhdjryvknn") else {
            self.progressBlock("Error constructing BTAPIClient.")
            return
        }

        ppNativeClient = BTPayPalNativeClient(apiClient: apiClient)
        ppNativeClient?.tokenizePayPalAccount(with: request) { (paypalAccountNonce, error) in
            button.isEnabled = true

            if let err = error {
                self.progressBlock(err.localizedDescription)
            }
            if let nonce = paypalAccountNonce {
                self.completionBlock(nonce)
            }
        }
    }
}
