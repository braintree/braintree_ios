import UIKit
import SwiftUI
import AuthenticationServices
import BraintreeCore
import BraintreeSEPADirectDebit

class SEPADirectDebitViewController: PaymentButtonBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SEPA Direct Debit"

        let demoView = SEPADirectDebitView(
            authorization: authorization,
            onProgress: progressBlock,
            onComplete: completionBlock
        )

        let hostingController = UIHostingController(rootView: demoView)
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        hostingController.didMove(toParent: self)
    }

    // This is to supress Constraint warnings when the payment button is not overriden. The actual Payment Button is within the SwiftUI view
    override func createPaymentButton() -> UIView {
        let placeholderView = UIView()
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        return placeholderView
    }
}
