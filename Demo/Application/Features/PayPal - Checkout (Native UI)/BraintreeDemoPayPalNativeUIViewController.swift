import UIKit

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
        button.setTitle(NSLocalizedString("PayPal Checkout (Native UI)", comment: ""), for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.setTitleColor(UIColor(red: 50.0 / 255, green: 50.0 / 255, blue: 255.0 / 255, alpha: 1.0), for: .highlighted)
        button.setTitleColor(UIColor.lightGray, for: .disabled)
        button.addTarget(self, action: #selector(tappedPayPalCheckout(_:)), for: .touchUpInside)
        return button
    }

    @objc func tappedPayPalCheckout(_ sender: UIButton?) {
        self.progressBlock("Tapped PayPal Checkout (Native UI) - using BTPayPalDriver")

        sender?.setTitle(NSLocalizedString("Processing...", comment: ""), for: .disabled)
        sender?.isEnabled = false

        // This demo uses a hard coded tokenization key.
        // You can find the corresponding accounts for "PayPal Native Checkout" in 1Password
        // TODO: obtain credentials for a BT-PP linked prod account. Update this demo to properly toggle b/w envs.
        let apiClient = BTAPIClient.init(authorization: "sandbox_8hpbq6nh_ks3tvzmhdjryvknn")
        let driver = BTPayPalDriver(apiClient: apiClient!)
        let request = BTPayPalCheckoutRequest(amount: "4.30")
        request.useNativeUI = true
        BTAppContextSwitcher.sharedInstance().payPalReturnURL = "tacocats://paypalpay"
        request.activeWindow = view.window
        driver.tokenizePayPalAccount(with: request) { [self] payPalAccount, error in
            sender?.isEnabled = true

            if let error = error {
                progressBlock(error.localizedDescription)
            } else if let payPalAccount = payPalAccount {
                self.completionBlock(payPalAccount)
            } else {
                progressBlock("Canceled")
            }
        }
    }

}
