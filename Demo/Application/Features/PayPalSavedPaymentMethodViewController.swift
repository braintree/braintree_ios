import UIKit
import BraintreePayPalSavedPaymentMethod

class PayPalSavedPaymentMethodViewController: PaymentButtonBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "PayPal Saved Payment Method"

        let demoView = PayPalSavedPaymentMethodDemoView(
            authorization: authorization,
            onProgress: progressBlock,
            onComplete: completionBlock
        )

        embed(demoView)
    }

    // TODO: Remove or change createPaymentButton during full SwiftUI migration
    // This is to suppress Constraint warnings when the payment button is not overriden.
    override func createPaymentButton() -> UIView {
        let placeholderView = UIView()
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        return placeholderView
    }
}
