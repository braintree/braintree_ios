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
import BraintreePayPalNativeCheckout
import BraintreeSEPADirectDebit

class ViewController: UIViewController {
    
    let authorization: String = "sandbox_9dbg82cq_dcpspy2brwdjr3qn"

    override func viewDidLoad() {
        // TODO: remove in the final PR for making authorization internal
        let apiClient = BTAPIClient(authorization: authorization)!

        let amexClient = BTAmericanExpressClient(authorization: authorization)
        let applePayClient = BTApplePayClient(authorization: authorization)
        let cardClient = BTCardClient(apiClient: apiClient)
        let dataCollector = BTDataCollector(apiClient: apiClient)
        let localPaymentClient = BTLocalPaymentClient(apiClient: apiClient)
        let payPalClient = BTPayPalClient(authorization: authorization)
        let payPalMessagingView = BTPayPalMessagingView(apiClient: apiClient)
        let threeDSecureClient = BTThreeDSecureClient(apiClient: apiClient)
        let venmoClient = BTVenmoClient(
            authorization: "sandbox_9dbg82cq_dcpspy2brwdjr3qn",
            universalLink: URL(string: "https://mobile-sdk-demo-site-838cead5d3ab.herokuapp.com/braintree-payments")!
        )
        let sepaDirectDebitClient = BTSEPADirectDebitClient(apiClient: apiClient)
    }
}

