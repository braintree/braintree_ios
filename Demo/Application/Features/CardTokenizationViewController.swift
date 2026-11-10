import UIKit
import BraintreeCard

class CardTokenizationViewController: PaymentButtonBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cardClient = BTCardClient(authorization: authorization)
        let demoView = CardTokenizationView(
            client: cardClient,
            onProgress: progressBlock,
            onComplete: completionBlock
        )
        embed(demoView)
    }
    
    // TODO: Remove or change createPaymentButton during full SwiftUI migration
    // This is to suppress the Constraint warnings when the payment button is not overriden.
    // The actual Payment Button is within the SwiftUI view.
    override func createPaymentButton() -> UIView {
        let placeholderView = UIView()
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        return placeholderView
    }
}
