import UIKit
import Braintree
import PassKit

class ViewController: UIViewController, PKPaymentAuthorizationViewControllerDelegate {

    let apiClient = try! BTAPIClient(clientKey: "test_client_key")
    var applePay : BTApplePayTokenizationClient

    required init(coder aDecoder: NSCoder) {
        applePay = BTApplePayTokenizationClient(APIClient: apiClient)
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: (PKPaymentAuthorizationStatus) -> Void) {

        applePay.tokenizeApplePayPayment(payment) { (tokenized, error) -> Void in
            if error != nil {
                print(error)
                completion(.Failure)
            } else {
                completion(.Success)
            }
        }

    }

    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController) {
        dismissViewControllerAnimated(true, completion: nil)

    }


}

