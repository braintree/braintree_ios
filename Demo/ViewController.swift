import UIKit
import BraintreeCore
import BraintreeApplePay
import BraintreePayPal
import BraintreeVenmo
import BraintreeUI
import PassKit

class ViewController: UIViewController, PKPaymentAuthorizationViewControllerDelegate, BTDropInViewControllerDelegate
{

    let apiClient = BTAPIClient(clientKey: "development_testing_integration_merchant_id")!
    var applePay : BTApplePayTokenizationClient
    var payPalDriver : BTPayPalDriver
    @IBOutlet weak var paymentButton: BTPaymentButton!

    required init?(coder aDecoder: NSCoder) {
        applePay = BTApplePayTokenizationClient(APIClient: apiClient)
        payPalDriver = BTPayPalDriver(APIClient: apiClient)
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        BTAppSwitch.sharedInstance().returnURLScheme = "com.braintreepayments.Demo"

        paymentButton.hidden = true

        /// In this example, we show how to make BTPaymentButton display only payment options
        /// that are enabled in Configuration. Alternatively, you can skip this, and the
        /// payment button will automatically show payment options whose frameworks are present.
        apiClient.fetchOrReturnRemoteConfiguration { (configuration, error) -> Void in
            guard let configuration = configuration else {
                return
            }

            var options = Array<String>()
            if configuration.isPayPalEnabled {
                options.append("PayPal")
            }
            if configuration.isVenmoEnabled {
                options.append("Venmo")
            }
            // TODO: Coinbase
            self.paymentButton.enabledPaymentOptions = NSOrderedSet(array: options)

            self.paymentButton.hidden = false
        }

        paymentButton.apiClient = apiClient
        paymentButton.completion = { (tokenized, error) in
            guard let tokenized = tokenized else {
                print("*** Failed to tokenize ***")
                if error != nil {
                    print("An error occurred: \(error)")
                } else {
                    print("Cancelled")
                }
                return
            }
            print("Got a nonce! \(tokenized.paymentMethodNonce)")
        }
   }

    @IBAction func payPalTapped(sender: UIButton) {
        let checkoutRequest = BTPayPalCheckoutRequest(amount: 1)

        payPalDriver.returnURLScheme = "com.braintreepayments.demo"

        payPalDriver.checkoutWithCheckoutRequest(checkoutRequest!) { (tokenizedCheckout, error) -> Void in
            guard let tokenizedCheckout = tokenizedCheckout else {
                print("Error during PayPal checkout: \(error)")
                // If Gateway is not accessible:
                // Optional(Error Domain=NSURLErrorDomain Code=-1004 "Could not connect to the server." UserInfo={NSUnderlyingError=0x7f80b27086a0 {Error Domain=kCFErrorDomainCFNetwork Code=-1004 "(null)" UserInfo={_kCFStreamErrorCodeKey=61, _kCFStreamErrorDomainKey=1}}, NSErrorFailingURLStringKey=http://localhost:3000/merchants/integration_merchant_id/client_api/v1/configuration?, NSErrorFailingURLKey=http://localhost:3000/merchants/integration_merchant_id/client_api/v1/configuration?, _kCFStreamErrorDomainKey=1, _kCFStreamErrorCodeKey=61, NSLocalizedDescription=Could not connect to the server.})
                // TODO: Add a loading indicator and block the button from being tapped multiple times while the configuration is being fetched
                
                return
            }

            print("Successfully checked out with PayPal. Nonce: \(tokenizedCheckout.paymentMethodNonce), Description: \(tokenizedCheckout.localizedDescription)")
        }
    }

    @IBAction func applePayTapped(sender: UIButton) {
        let paymentRequest = PKPaymentRequest()
        paymentRequest.merchantIdentifier = "merchant.prodapplepaytestinghouzz"
        paymentRequest.supportedNetworks = [PKPaymentNetworkAmex, PKPaymentNetworkVisa, PKPaymentNetworkMasterCard]
        paymentRequest.merchantCapabilities = PKMerchantCapability.Capability3DS
        paymentRequest.countryCode = "US"
        paymentRequest.paymentSummaryItems = [ PKPaymentSummaryItem(label: "Nothing", amount: NSDecimalNumber(string: "1"))]
        paymentRequest.currencyCode = "USD"

        let viewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
        viewController.delegate = self

        presentViewController(viewController, animated: true, completion: nil)
    }

    @IBAction func showDropIn(sender: UIButton) {
        let dropIn = BTDropInViewController(APIClient: apiClient)

        dropIn.delegate = self

//        dropIn.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "dismissModal")
        let navigationController = UINavigationController(rootViewController: dropIn)
        presentViewController(navigationController, animated: true, completion: nil)
    }

    func dismissModal() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: (PKPaymentAuthorizationStatus) -> Void) {

        applePay.tokenizeApplePayPayment(payment) { (tokenized, error) -> Void in
            if error != nil {
                print(error)
                completion(.Failure)
            } else {
                self.applePay.tokenizeApplePayPayment(payment, completion: { (tokenizedApplePay, error) -> Void in
                    guard let tokenizedApplePay = tokenizedApplePay else {
                        print("Failed to tokenize Apple Pay payment: \(error)")
                        return;
                    }
                    print("Successfully tokenized Apple Pay payment! Nonce: \(tokenizedApplePay.paymentMethodNonce)")
                })
                completion(.Success)
            }
        }

    }

    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func venmoTapped(sender: UIButton) {
        let venmoDriver = BTVenmoDriver(APIClient: apiClient)
        venmoDriver.tokenizeVenmoCardWithCompletion { (tokenizedCard, error) -> Void in
            print("tokenizedCard = \(tokenizedCard), error = \(error)")
        }
    }

    func dropInViewController(viewController: BTDropInViewController!, didSucceedWithTokenization tokenization: BTTokenized!) {
        print("Tokenization succeeded with nonce: \(tokenization.paymentMethodNonce)")
        dismissModal()
    }

    func dropInViewControllerDidCancel(viewController: BTDropInViewController!) {
        print("Tokenization was cancelled")
    }

    func dropInViewControllerWillComplete(viewController: BTDropInViewController!) {
        print("Received delegate message: tokenization will complete")
    }

}

