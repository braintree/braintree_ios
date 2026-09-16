import UIKit
import BraintreeAmericanExpress
import BraintreeCard

class AmexViewController: PaymentButtonBaseViewController {

    lazy var amexClient = BTAmericanExpressClient(authorization: authorization)
    lazy var cardClient = BTCardClient(authorization: authorization)

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Amex"

        let demoView = AmexView(
            amexClient: amexClient,
            cardClient: cardClient,
            onProgress: progressBlock,
            onComplete: completionBlock
        )
        embed(demoView)
    }

    // TODO: Remove or change createPaymentButton during full SwiftUI migration
    // This is to suppress Constraint warnings when the payment button is not overriden.
    // The actual Payment Button is within the SwiftUI view.
    override func createPaymentButton() -> UIView {
        let placeholderView = UIView()
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        return placeholderView
    }
}
