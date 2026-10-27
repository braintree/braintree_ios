import UIKit
import BraintreeLocalPayment
import BraintreeCore

class IdealViewController: PaymentButtonBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "iDEAL"

        progressBlock("Fetching client token for ideal_eur merchant account...")

        // A client token scoped to the ideal_eur merchant account is required so that
        // PayPal resolves the payee as the PayPal account connected to ideal_eur, rather
        // than the default merchant account associated with a tokenization key.
        NSLog("[iDEAL] Fetching client token scoped to merchant account: ideal_eur")

        BraintreeDemoMerchantAPIClient.shared.createCustomerAndFetchClientToken(
            merchantAccountID: "ideal_eur"
        ) { [weak self] clientToken, error in
            guard let self else { return }

            guard let clientToken else {
                NSLog("[iDEAL] Client token fetch failed: %@", error?.localizedDescription ?? "unknown error")
                self.progressBlock("Error fetching client token: \(error?.localizedDescription ?? "unknown error")")
                return
            }

            NSLog("[iDEAL] Client token fetched successfully, length: %d", clientToken.count)

            let demoView = IdealView(
                client: BTLocalPaymentClient(authorization: clientToken),
                onProgress: self.progressBlock,
                onComplete: self.completionBlock
            )
            self.embed(demoView)
        }
    }

    // TODO: Remove or change createPaymentButton during full SwiftUI migration
    // This is to suppress Constraint warnings when the payment button is not overridden. The actual Payment Button is within the SwiftUI view
    override func createPaymentButton() -> UIView {
        let placeholderView = UIView()
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        return placeholderView
    }
}
