import UIKit
import PayPalCheckout

protocol BTPayPalNativeCheckoutProtocol {

    static var showsExitAlert: Bool { get set }

    // swiftlint:disable function_parameter_count
    static func start(
        presentingViewController: UIViewController?,
        createOrder: CheckoutConfig.CreateOrderCallback?,
        onApprove: CheckoutConfig.ApprovalCallback?,
        onShippingChange: CheckoutConfig.ShippingChangeCallback?,
        onCancel: CheckoutConfig.CancelCallback?,
        onError: CheckoutConfig.ErrorCallback?
    )
    // swiftlint:enable function_parameter_count

    static func set(config: CheckoutConfig)
}

extension Checkout: BTPayPalNativeCheckoutProtocol { }
