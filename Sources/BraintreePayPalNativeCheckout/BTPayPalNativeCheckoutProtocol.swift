import UIKit
import PayPalCheckout

protocol BTPayPalNativeCheckoutProtocol {

    static var showsExitAlert: Bool { get set }

    static func start(
        presentingViewController: UIViewController?,
        createOrder: PayPalCheckout.CheckoutConfig.CreateOrderCallback?,
        onApprove: PayPalCheckout.CheckoutConfig.ApprovalCallback?,
        onShippingChange: PayPalCheckout.CheckoutConfig.ShippingChangeCallback?,
        onCancel: PayPalCheckout.CheckoutConfig.CancelCallback?,
        onError: PayPalCheckout.CheckoutConfig.ErrorCallback?
    )

    static func set(config: CheckoutConfig)
}

extension Checkout: BTPayPalNativeCheckoutProtocol { }
