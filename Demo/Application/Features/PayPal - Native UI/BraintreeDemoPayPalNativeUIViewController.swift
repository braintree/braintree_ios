import UIKit
import BraintreePayPalNative

class BraintreeDemoPayPalNativeUIViewController: BraintreeDemoPaymentButtonBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textAlignment = .center
        textView.text = "This demo is using a hard-coded tokenization key for a BT sandbox with a linked PayPal sandbox account."
        self.view.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.widthAnchor.constraint(equalTo: view.widthAnchor),
            textView.topAnchor.constraint(equalTo: self.paymentButton.bottomAnchor),
            textView.heightAnchor.constraint(equalToConstant: 60.0)
        ])
    }

    override func createPaymentButton() -> UIView? {
        let button = UIButton(type: .custom)
        button.setTitle(NSLocalizedString("PayPal - Native UI", comment: ""), for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.setTitleColor(UIColor(red: 50.0 / 255, green: 50.0 / 255, blue: 255.0 / 255, alpha: 1.0), for: .highlighted)
        button.setTitleColor(UIColor.lightGray, for: .disabled)
        button.addTarget(self, action: #selector(tappedPayPalNativeCheckout(_:)), for: .touchUpInside)
        return button
    }

    @objc func tappedPayPalNativeCheckout(_ button: UIButton?) {
        self.progressBlock("Tapped PayPal - Native UI: using BTPayPalNativeClient")

        button?.setTitle(NSLocalizedString("Processing...", comment: ""), for: .disabled)
        button?.isEnabled = false

        // This demo uses a hard coded tokenization key.
        // You can find the corresponding accounts for "PayPal Native Checkout" in 1Password.
        // TODO: obtain credentials for a BT-PP linked prod account. Update this demo to properly toggle b/w envs.
        guard let apiClient = BTAPIClient(authorization: "sandbox_8hpbq6nh_ks3tvzmhdjryvknn") else {
            self.progressBlock("Error constructing BTAPIClient.")
            return
        }

        let request = BTPayPalNativeCheckoutRequest(payPalReturnURL: "tacocats://paypalpay", amount: "10.00")

        let ppNativeClient = BTPayPalNativeClient(apiClient: apiClient)
        ppNativeClient.tokenizePayPalAccount(with: request) { (paypalAccountNonce, error) in
            if (error != nil) {
                self.progressBlock(error?.localizedDescription)
            }
            if let nonce = paypalAccountNonce {
                self.completionBlock(nonce)
            }
        }
    }

}
