import Foundation
import PayPalCheckout

#if canImport(BraintreePayPal)
import BraintreePayPal
#endif

@available(*, deprecated, message: "BraintreePayPalNativeCheckout Module is deprecated, use BraintreePayPal Module instead")
class BTPayPalNativeCheckoutProvider: BTPayPalNativeCheckoutStartable {

    /// Used in POST body for FPTI analytics.
    var clientMetadataID: String?

    private let checkout: BTPayPalNativeCheckoutProtocol.Type

    init(_ mxo: BTPayPalNativeCheckoutProtocol.Type = Checkout.self) {
        self.checkout = mxo
    }

    // swiftlint:disable function_parameter_count
    func start(
        request: BTPayPalRequest,
        order: BTPayPalNativeOrder,
        nxoConfig: CheckoutConfig,
        onStartableApprove: @escaping StartableApproveCallback,
        onStartableCancel: @escaping StartableCancelCallback,
        onStartableError: @escaping StartableErrorCallback
    ) {
        checkout.showsExitAlert = false
        checkout.set(config: nxoConfig)

        checkout.start(
            presentingViewController: nil,
            createOrder: { [weak self] action in
                guard self != nil else {
                    onStartableError(.deallocated)
                    return
                }

                switch request.paymentType {
                case .checkout:
                    action.set(orderId: order.orderID)
                case .vault:
                    action.set(billingAgreementToken: order.orderID)
                @unknown default:
                    onStartableError(.invalidRequest)
                }
            },
            onApprove: { [weak self] approval in
                guard let self else {
                    onStartableError(.deallocated)
                    return
                }
                self.clientMetadataID = approval.data.correlationIDs.riskCorrelationID
                onStartableApprove(approval.data.returnURL?.absoluteString, approval.data.buyer)
            },
            onShippingChange: nil,
            onCancel: {
                onStartableCancel()
                return
            },
            onError: { error in
                self.clientMetadataID = error.correlationIDs.riskCorrelationID
                onStartableError(.checkoutSDKFailed(error))
            }
        )

        NotificationCenter.default.post(name: Notification.Name("brain_tree_source_event"), object: nil)
    }
    // swiftlint:enable function_parameter_count
}
