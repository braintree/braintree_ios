import Foundation
import PayPalCheckout

#if canImport(BraintreePayPal)
import BraintreePayPal
#endif

protocol BTPayPalNativeCheckoutStartable {

    func start(
        request: BTPayPalRequest,
        order: BTPayPalNativeOrder,
        nxoConfig: CheckoutConfig,
        completion: @escaping (Result<Approval, BTPayPalNativeCheckoutError>) -> Void
    )
}
