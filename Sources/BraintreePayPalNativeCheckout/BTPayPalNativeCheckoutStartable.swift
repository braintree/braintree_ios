import Foundation
import PayPalCheckout

#if canImport(BraintreePayPal)
import BraintreePayPal
#endif

protocol BTPayPalNativeCheckoutStartable {

    typealias StartableApproveCallback = (String?, User?) -> Void
    typealias StartableErrorCallback = (BTPayPalNativeCheckoutError) -> Void
    typealias StartableCancelCallback = () -> Void

    func start(
        request: BTPayPalRequest,
        order: BTPayPalNativeOrder,
        nxoConfig: CheckoutConfig,
        onStartableApprove: @escaping StartableApproveCallback,
        onStartableCancel: @escaping StartableCancelCallback,
        onStartableError: @escaping StartableErrorCallback
    )
}
