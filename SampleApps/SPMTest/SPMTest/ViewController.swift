import UIKit
import SwiftUI
import BraintreeAmericanExpress
import BraintreeApplePay
import BraintreeCard
import BraintreeCore
import BraintreeDataCollector
import BraintreeLocalPayment
import BraintreePayPal
import BraintreePayPalMessaging
import BraintreeThreeDSecure
import BraintreeVenmo
import BraintreeSEPADirectDebit
import BraintreeUIComponents

class ViewController: UIViewController {
    private var hostingController: UIHostingController<VenmoButton>?
    
    let authorization: String = "sandbox_9dbg82cq_dcpspy2brwdjr3qn"

    override func viewDidLoad() {
        let amexClient = BTAmericanExpressClient(authorization: authorization)
        let applePayClient = BTApplePayClient(authorization: authorization)
        let cardClient = BTCardClient(authorization: authorization)
        let dataCollector = BTDataCollector(authorization: authorization)
        let localPaymentClient = BTLocalPaymentClient(authorization: authorization)
        let payPalClient = BTPayPalClient(authorization: authorization)
        let payPalMessagingView = BTPayPalMessagingView(authorization: authorization)
        let threeDSecureClient = BTThreeDSecureClient(authorization: authorization)
        let venmoClient = BTVenmoClient(
            authorization: authorization,
            universalLink: URL(string: "https://mobile-sdk-demo-site-838cead5d3ab.herokuapp.com/braintree-payments")!
        )
        let sepaDirectDebitClient = BTSEPADirectDebitClient(authorization: authorization)
        setupVenmoButton()
    }
    
    private func setupVenmoButton() {
        let venmoRequest = BTVenmoRequest(paymentMethodUsage: .singleUse)
        
        let venmoButton = VenmoButton(
            authorization: authorization,
            universalLink: URL(string: "https://example.com")!,
            request: venmoRequest,
            color: .blue,
            width: 300
        ) { nonce, error in
            print("Button tapped")
        }
        
        hostingController = UIHostingController(rootView: venmoButton)
        guard let hostingController else { return }
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hostingController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            hostingController.view.widthAnchor.constraint(equalToConstant: 300),
            hostingController.view.heightAnchor.constraint(equalToConstant: 45)
        ])
        
        hostingController.didMove(toParent: self)
    }
}
