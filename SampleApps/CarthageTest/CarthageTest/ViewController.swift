import UIKit
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
import SwiftUI
import UIKit

class ViewController: UIViewController {
    
    let authorization: String = "sandbox_9dbg82cq_dcpspy2brwdjr3qn"
    private var venmoHostingController: UIHostingController<VenmoButton>?
    private var paypalHostingController: UIHostingController<PayPalButton>?

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
        setupPayPalButton()
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
        
        venmoHostingController = UIHostingController(rootView: venmoButton)
        guard let venmoHostingController else { return }
        
        addChild(venmoHostingController)
        view.addSubview(venmoHostingController.view)
        
        venmoHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            venmoHostingController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            venmoHostingController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            venmoHostingController.view.widthAnchor.constraint(equalToConstant: 300),
            venmoHostingController.view.heightAnchor.constraint(equalToConstant: 45)
        ])
        
        venmoHostingController.didMove(toParent: self)
    }
    
    private func setupPayPalButton() {
        let paypalRequest = BTPayPalCheckoutRequest(amount: "10.00")
        
        let paypalButton = PayPalButton(
            authorization: authorization,
            request: paypalRequest,
            color: .blue,
            width: 300
        ) { (nonce, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else if let nonce = nonce {
                print("PayPal Account Nonce: \(nonce)")
            }
        }
        
        paypalHostingController = UIHostingController(rootView: paypalButton)
        guard let paypalHostingController else { return }
        
        addChild(paypalHostingController)
        view.addSubview(paypalHostingController.view)
        
        paypalHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            paypalHostingController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            paypalHostingController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            paypalHostingController.view.widthAnchor.constraint(equalToConstant: 300),
            paypalHostingController.view.heightAnchor.constraint(equalToConstant: 45)
        ])
        
        paypalHostingController.didMove(toParent: self)
    }
}
