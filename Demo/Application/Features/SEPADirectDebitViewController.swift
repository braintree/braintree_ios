import UIKit
import AuthenticationServices
import BraintreeCore
import BraintreeSEPADirectDebit

class SEPADirectDebitViewController: PaymentButtonBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SEPA Direct Debit"

        let demoView = SEPADirectDebitView(
            client: BTSEPADirectDebitClient(authorization: authorization),
            onProgress: progressBlock,
            onComplete: completionBlock
        )

        embed(demoView)
    }

    // TODO: Remove or change createPaymentButton during full SwiftUI migration
    // This is to suppress Constraint warnings when the payment button is not overriden. The actual Payment Button is within the SwiftUI view
    override func createPaymentButton() -> UIView {
        let placeholderView = UIView()
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        return placeholderView
    }
}
