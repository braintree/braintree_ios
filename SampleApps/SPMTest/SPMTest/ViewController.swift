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

class ViewController: UIViewController {

    override func viewDidLoad() {
        // TODO: remove in the final PR for making authorization internal
        let apiClient = BTAPIClient(authorization: "sandbox_9dbg82cq_dcpspy2brwdjr3qn")!

        let amexClient = BTAmericanExpressClient(authorization: "sandbox_9dbg82cq_dcpspy2brwdjr3qn")
        let applePayClient = BTApplePayClient(apiClient: apiClient)
        let cardClient = BTCardClient(apiClient: apiClient)
        let dataCollector = BTDataCollector(apiClient: apiClient)
        let localPaymentClient = BTLocalPaymentClient(apiClient: apiClient)
        let payPalClient = BTPayPalClient(authorization: "sandbox_9dbg82cq_dcpspy2brwdjr3qn")
        let payPalMessagingView = BTPayPalMessagingView(apiClient: apiClient)
        let threeDSecureClient = BTThreeDSecureClient(apiClient: apiClient)
        let venmoClient = BTVenmoClient(
            apiClient: apiClient,
            universalLink: URL(string: "https://mobile-sdk-demo-site-838cead5d3ab.herokuapp.com/braintree-payments")!
        )
        let sepaDirectDebitClient = BTSEPADirectDebitClient(apiClient: apiClient)
    }
}
