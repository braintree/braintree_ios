import XCTest
import UIKit
import PayPalCheckout
@testable import BraintreePayPalNativeCheckout

class BTPayPalNativeCheckoutProvider_Tests: XCTestCase {

    func testStart_whenStartIsCalled_checkoutIsInitialized() {
        let nativeCheckoutProvider = BTPayPalNativeCheckoutProvider(MockCheckout.self)
        nativeCheckoutProvider.start(
            request: BTPayPalNativeVaultRequest(),
            order: BTPayPalNativeOrder(payPalClientID: "", environment: .sandbox, orderID: ""),
            nxoConfig: CheckoutConfig(clientID: ""),
            onStartableApprove: { _, _ in },
            onStartableCancel: { },
            onStartableError: { _ in }
        )

        XCTAssertTrue(MockCheckout.startInvoked)
        XCTAssertTrue(MockCheckout.isConfigSet)
        XCTAssertFalse(MockCheckout.showsExitAlert)
    }
}

class MockCheckout: BTPayPalNativeCheckoutProtocol {

    static var showsExitAlert = false
    static var startInvoked = false
    static var isConfigSet = false

    static func start(
        presentingViewController: UIViewController?,
        createOrder: CheckoutConfig.CreateOrderCallback?,
        onApprove: CheckoutConfig.ApprovalCallback?,
        onShippingChange: CheckoutConfig.ShippingChangeCallback?,
        onCancel: CheckoutConfig.CancelCallback?,
        onError: CheckoutConfig.ErrorCallback?
    ) {
        startInvoked = true
    }

    static func set(config: PayPalCheckout.CheckoutConfig) {
        isConfigSet = true
    }
}
