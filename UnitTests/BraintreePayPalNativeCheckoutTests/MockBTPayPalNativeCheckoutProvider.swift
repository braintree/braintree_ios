import Foundation
import PayPalCheckout
@testable import BraintreePayPal
@testable import BraintreePayPalNativeCheckout

class MockBTPayPalNativeCheckoutProvider: BTPayPalNativeCheckoutStartable {

    var userAuthenticationEmail: String?
    var onCancel: StartableCancelCallback?
    var onError: StartableErrorCallback?
    var onApprove: StartableApproveCallback?

    var didCancel: Bool = false
    var didApprove: Bool = false
    var error: Error?

    required init(nxoConfig: CheckoutConfig) { }

    func start(
        request: BTPayPalRequest,
        order: BTPayPalNativeOrder,
        nxoConfig: CheckoutConfig,
        onStartableApprove: @escaping StartableApproveCallback,
        onStartableCancel: @escaping StartableCancelCallback,
        onStartableError: @escaping StartableErrorCallback
    ) {
        self.onApprove = onStartableApprove
        self.onCancel = onStartableCancel
        self.onError = onStartableError
        self.userAuthenticationEmail = nxoConfig.authConfig.userEmail
    }

    func triggerCancel() {
        didCancel = true
    }

    func triggerError(error: BTPayPalNativeCheckoutError) {
        self.error = error
    }

    func triggerApprove(returnURL: String) {
        didApprove = true
    }
}
