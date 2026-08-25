import UIKit
import BraintreeCore
import BraintreePayPal
import BraintreePayPalSavedPaymentMethod

class PayPalSavedPaymentMethodViewController: PaymentButtonBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "PayPal Saved Payment Method"

        // swiftlint:disable:next force_unwrapping
        let universalLink = URL(string: "https://mobile-sdk-demo-site-838cead5d3ab.herokuapp.com/braintree-payments")!
        let payPalCheckoutRequest = BTPayPalCheckoutRequest(amount: "10.00", enablePayPalAppSwitch: true)
        let request = BTPayPalSavedPaymentMethodRequest(amount: "10.00", currencyCode: "USD")

        embed(
            BTPayPalSavedPaymentMethodView(
                payPalCheckoutRequest: payPalCheckoutRequest,
                request: request,
                authorization: authorization,
                universalLink: universalLink,
                fallbackURLScheme: "com.braintreepayments.Demo.payments"
            ) { [weak self] nonce, error in
                guard let self else { return }
                if let error {
                    self.progressBlock(error.localizedDescription)
                    return
                }
                self.completionBlock(nonce)
            }
        )
    }

    override func createPaymentButton() -> UIView {
        let placeholderView = UIView()
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        return placeholderView
    }
}
