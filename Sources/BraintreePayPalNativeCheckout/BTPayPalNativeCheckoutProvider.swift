import Foundation
import PayPalCheckout

#if canImport(BraintreePayPal)
import BraintreePayPal
#endif

class BTPayPalNativeCheckoutProvider: BTPayPalNativeCheckoutStartable {

    /// Used in POST body for FPTI analytics.
    var clientMetadataID: String?

    private let checkout: BTPayPalNativeCheckoutProtocol.Type

    init(_ mxo: BTPayPalNativeCheckoutProtocol.Type = Checkout.self) {
        self.checkout = mxo
    }

    func start(
        request: BTPayPalRequest,
        order: BTPayPalNativeOrder,
        nxoConfig: CheckoutConfig,
        completion: @escaping (Result<Approval, BTPayPalNativeCheckoutError>) -> Void
    ) {
        checkout.showsExitAlert = false
        checkout.set(config: nxoConfig)

        checkout.start(
            presentingViewController: nil,
            createOrder: { [weak self] action in
                guard let self else {
                    completion(.failure(.deallocated))
                    return
                }

                switch request.paymentType {
                case .checkout:
                    action.set(orderId: order.orderID)
                case .vault:
                    action.set(billingAgreementToken: order.orderID)
                @unknown default:
                    completion(.failure(.invalidRequest))
                }
            },
            onApprove: { [weak self] approval in
                guard let self else {
                    completion(.failure(.deallocated))
                    return
                }
                self.clientMetadataID = approval.data.correlationIDs.riskCorrelationID
                completion(.success(approval))
            }, 
            onShippingChange: nil,
            onCancel: {
                completion(.failure(.canceled))
                return
            },
            onError: { error in
                self.clientMetadataID = error.correlationIDs.riskCorrelationID
                completion(.failure(.checkoutSDKFailed(error)))
            }
        )

        NotificationCenter.default.post(name: Notification.Name("brain_tree_source_event"), object: nil)
    }
}
