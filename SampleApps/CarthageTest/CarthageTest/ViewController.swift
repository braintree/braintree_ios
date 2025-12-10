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
        
        // draw PayPal branded button
        let paypalRequest = BTPayPalCheckoutRequest(amount: "10.00")
        let paypalButton = PayPalButton(
            authorization: authorization,
            request: paypalRequest,
            color: .black,
            width: 300
        ) { (nonce, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else if let nonce = nonce {
                print("PayPal Account Nonce: \(nonce)")
            }
        }

        
        // draw Venmo branded button
        let venmoRequest = BTVenmoRequest(paymentMethodUsage: .singleUse)
        let venmoButton = VenmoButton(
            authorization: authorization,
            universalLink: URL(string: "https://mobile-sdk-demo-site-838cead5d3ab.herokuapp.com/braintree-payments")!,
            request: venmoRequest,
            color: .blue,
            width: 300
        ) { (nonce, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else if let nonce = nonce {
                print("Venmo Account Nonce: \(nonce)")
            }
        }

    }
}
