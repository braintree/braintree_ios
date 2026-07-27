import Foundation
import BraintreeApplePay
import PassKit

class ApplePayViewController: PaymentButtonBaseViewController {

    lazy var applePayClient = BTApplePayClient(authorization: authorization)

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Apple Pay"

        let demoView = ApplePayView(
            client: applePayClient,
            onProgress: progressBlock,
            onComplete: completionBlock
        ) { [weak self] paymentRequest in
            self?.presentPaymentSheet(with: paymentRequest)
        }

        embed(demoView)
    }

    // TODO: Remove or change createPaymentButton during full SwiftUI migration
    // This is to suppress Constraint warnings when the payment button is not overriden. The actual Payment Button is within the SwiftUI view
    override func createPaymentButton() -> UIView {
        let placeholderView = UIView()
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        return placeholderView
    }

    private func presentPaymentSheet(with paymentRequest: PKPaymentRequest) {
        guard let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) else {
            progressBlock("Could not create PKPaymentAuthorizationViewController")
            return
        }
        paymentAuthorizationViewController.delegate = self
        present(paymentAuthorizationViewController, animated: true)
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
