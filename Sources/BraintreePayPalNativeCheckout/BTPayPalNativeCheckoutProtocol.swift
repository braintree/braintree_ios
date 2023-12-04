import UIKit
import PayPalCheckout

protocol BTPayPalNativeCheckoutProtocol {

    static var showsExitAlert: Bool { get set }

    static func start(
        presentingViewController: UIViewController?,
        createOrder: CheckoutConfig.CreateOrderCallback?,
        onApprove: CheckoutConfig.ApprovalCallback?,
        onShippingChange: CheckoutConfig.ShippingChangeCallback?,
        onCancel: CheckoutConfig.CancelCallback?,
        onError: CheckoutConfig.ErrorCallback?
    )

    static func set(config: CheckoutConfig)
}

extension Checkout: BTPayPalNativeCheckoutProtocol { }
