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

    override func viewDidLoad() {
        let apiClient = BTAPIClient(authorization: "sandbox_9dbg82cq_dcpspy2brwdjr3qn")!

        let amexClient = BTAmericanExpressClient(apiClient: apiClient)
        let applePayClient = BTApplePayClient(apiClient: apiClient)
        let cardClient = BTCardClient(apiClient: apiClient)
        let dataCollector = BTDataCollector(apiClient: apiClient)
        let localPaymentClient = BTLocalPaymentClient(apiClient: apiClient)
        let payPalClient = BTPayPalClient(apiClient: apiClient)
        let payPalMessagingView = BTPayPalMessagingView(apiClient: apiClient)
        let threeDSecureClient = BTThreeDSecureClient(apiClient: apiClient)
        let venmoClient = BTVenmoClient(apiClient: apiClient)
        let payPalNativeCheckoutClient = BTPayPalNativeCheckoutClient(apiClient: apiClient)
        let sepaDirectDebitClient = BTSEPADirectDebitClient(apiClient: apiClient)
    }
}
