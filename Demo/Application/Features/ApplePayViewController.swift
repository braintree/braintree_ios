import Foundation
import BraintreeApplePay
import PassKit

class ApplePayViewController: PaymentButtonBaseViewController {

    lazy var applePayClient = BTApplePayClient(apiClient: apiClient)
    // swiftlint:disable:next force_unwrapping
    let managementURL = URL(string: "https://www.merchant.com/update-payment")!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Apple Pay"
    }

    override func createPaymentButton() -> UIView {
        if !PKPaymentAuthorizationViewController.canMakePayments() {
            progressBlock("canMakePayments returned false, hiding Apple Pay button")
        }

        let applePayButton = PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: .automatic)
        applePayButton.translatesAutoresizingMaskIntoConstraints = false
        applePayButton.addTarget(self, action: #selector(tappedApplePayButton), for: .touchUpInside)

        NSLayoutConstraint.activate([applePayButton.heightAnchor.constraint(equalToConstant: 50)])

        return applePayButton
    }

    @objc func tappedApplePayButton() {
        progressBlock("Constructing PKPaymentRequest")

        applePayClient.makePaymentRequest { request, error in
            guard let request else {
                self.progressBlock(error?.localizedDescription)
                return
            }

            let paymentRequest = self.constructPaymentRequest(with: request)
            guard let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) else {
                self.progressBlock("Could not create PKPaymentAuthorizationViewController")
                return
            }
            paymentAuthorizationViewController.delegate = self

            if #available(iOS 16.0, *) {
                paymentRequest.recurringPaymentRequest = self.recurringPaymentRequest()
            }

            self.progressBlock("Presenting Apple Pay Sheet")
            self.present(paymentAuthorizationViewController, animated: true)
        }
    }

    @available(iOS 16.0, *)
    private func recurringPaymentRequest() -> PKRecurringPaymentRequest {
        let recurringPaymentRequest = PKRecurringPaymentRequest(
            paymentDescription: "Payment description.",
            regularBilling: PKRecurringPaymentSummaryItem(label: "Payment label", amount: 10.99),
            managementURL: managementURL
        )
        return recurringPaymentRequest
    }

    private func constructPaymentRequest(with paymentRequest: PKPaymentRequest) -> PKPaymentRequest {
        paymentRequest.requiredBillingContactFields = [PKContactField.name]

        let shippingMethod1 = PKShippingMethod(label: "✈️ Fast Shipping", amount: 4.99)
        shippingMethod1.detail = "Fast but expensive"
        shippingMethod1.identifier = "fast"

        let shippingMethod2 = PKShippingMethod(label: "🐢 Slow Shipping", amount: 0.00)
        shippingMethod2.detail = "Slow but free"
        shippingMethod2.identifier = "slow"

        let shippingMethod3 = PKShippingMethod(label: "💣 Unavailable Shipping", amount: NSDecimalNumber(string: "0xdeadbeef"))
        shippingMethod3.detail = "It will make Apple Pay fail"
        shippingMethod3.identifier = "fail"

        paymentRequest.shippingMethods = [shippingMethod1, shippingMethod2, shippingMethod3]
        paymentRequest.requiredShippingContactFields = [PKContactField.name, PKContactField.phoneNumber, PKContactField.emailAddress]

        paymentRequest.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "SOME ITEM", amount: 10),
            PKPaymentSummaryItem(label: "SHIPPING", amount: shippingMethod1.amount),
            PKPaymentSummaryItem(label: "BRAINTREE", amount: 14.99)
        ]

        paymentRequest.merchantCapabilities = .capability3DS
        return paymentRequest
    }
}

// MARK: - PKPaymentAuthorizationViewControllerDelegate Conformance

extension ApplePayViewController: PKPaymentAuthorizationViewControllerDelegate {

    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true)
    }

    func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        progressBlock("Apple Pay did authorize payment")

        applePayClient.tokenize(payment) { tokenizedApplePayPayment, error in
            guard let tokenizedApplePayPayment else {
                self.progressBlock(error?.localizedDescription)
                completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
                return
            }

            self.completionBlock(tokenizedApplePayPayment)
            completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
        }
    }

    func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didSelect shippingMethod: PKShippingMethod,
        handler completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void
    ) {
        let testItem = PKPaymentSummaryItem(label: "SOME ITEM", amount: 10)
        let shippingMethodUpdate = PKPaymentRequestShippingMethodUpdate(paymentSummaryItems: [testItem])

        if shippingMethod.identifier == "fail" {
            shippingMethodUpdate.status = .failure
        }

        completion(shippingMethodUpdate)
    }

    func paymentAuthorizationViewControllerWillAuthorizePayment(_ controller: PKPaymentAuthorizationViewController) {
        progressBlock("Apple Pay will authorize payment")
    }
}
