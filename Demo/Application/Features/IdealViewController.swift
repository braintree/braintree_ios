import UIKit
import BraintreeLocalPayment
import BraintreeCore

class IdealViewController: PaymentButtonBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "iDEAL"
        
        let demoView = IdealView(
            client: BTLocalPaymentClient(authorization: "sandbox_f252zhq7_hh4cpc39zq4rgjcg"),
            onProgress: progressBlock,
            onComplete: completionBlock
        )
        embed(demoView)
    }

    // TODO: Remove or change createPaymentButton during full SwiftUI migration
    // This is to suppress Constraint warnings when the payment button is not overridden. The actual Payment Button is within the SwiftUI view
    override func createPaymentButton() -> UIView {
        let placeholderView = UIView()
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        return placeholderView
    }
}
