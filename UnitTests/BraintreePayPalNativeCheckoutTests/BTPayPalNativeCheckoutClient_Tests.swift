import XCTest
import PayPalCheckout
@testable import BraintreeTestShared
@testable import BraintreePayPalNativeCheckout
@testable import BraintreeCore
@testable import BraintreePayPal

class BTPayPalNativeCheckoutClient_Tests: XCTestCase {
    var apiClient: MockAPIClient!
    let nxoConfig = CheckoutConfig(
        clientID: "testClientID",
        createOrder: nil,
        onApprove: nil,
        onShippingChange: nil,
        onCancel: nil,
        onError: nil,
        environment: .sandbox
    )

    lazy var mockNativeCheckoutProvider = MockBTPayPalNativeCheckoutProvider(nxoConfig: nxoConfig)

    override func setUp() {
        super.setUp()
        apiClient = MockAPIClient(authorization: "development_client_key")
    }

    func testInvalidConfiguration_ReturnsCorrectError() {
        let environment = "sandbox"
        apiClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "environment": environment,
            "paypal": ["clientId": nil] as [String: Any?]
        ] as [String: Any])

        let nativeCheckoutRequest = BTPayPalNativeCheckoutRequest(amount: "4.30")
        let checkoutClient = BTPayPalNativeCheckoutClient(apiClient: apiClient)
        checkoutClient.tokenize(nativeCheckoutRequest) { nonce, error in
            XCTAssertNil(nonce)
            XCTAssertEqual(error as? BTPayPalNativeCheckoutError, .payPalClientIDNotFound)
            XCTAssertEqual(self.apiClient.postedAnalyticsEvents.last, BTPayPalNativeCheckoutAnalytics.tokenizeFailed)
        }
    }

    func testUserAuthenticationIsPassed_returnsRequestEmail() {
        apiClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "environment": "sandbox",
            "paypal": ["clientId": "a-fake-client-id"] as [String: Any?]
        ] as [String: Any])

        apiClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": ["redirectUrl": "https://www.paypal.com/checkout?token=fake-ec-token"]
        ])

        let payPalNativeCheckoutClient = BTPayPalNativeCheckoutClient(apiClient: apiClient, nativeCheckoutProvider: mockNativeCheckoutProvider)
        let request = BTPayPalNativeCheckoutRequest(amount: "1.99", userAuthenticationEmail: "fake_user_email@mock.paypal.com")
        payPalNativeCheckoutClient.tokenize(request) { _, _ in }
        XCTAssertEqual(mockNativeCheckoutProvider.userAuthenticationEmail, "fake_user_email@mock.paypal.com")
    }

    func testUserAuthenticationIsNil_returnsNilForEmail() {
        apiClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "environment": "sandbox",
            "paypal": ["clientId": "a-fake-client-id"] as [String: Any?]
        ] as [String: Any])

        apiClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": ["redirectUrl": "https://www.paypal.com/checkout?token=fake-ec-token"]
        ])

        let payPalNativeCheckoutClient = BTPayPalNativeCheckoutClient(apiClient: apiClient, nativeCheckoutProvider: mockNativeCheckoutProvider)
        let request = BTPayPalNativeCheckoutRequest(amount: "1.99")
        payPalNativeCheckoutClient.tokenize(request) { _, _ in }
        XCTAssertNil(mockNativeCheckoutProvider.userAuthenticationEmail)
    }

    func testTokenize_whenOnStartableApproved_returnsDidApprove() {
        apiClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "environment": "sandbox",
            "paypal": ["clientId": "a-fake-client-id"] as [String: Any?]
        ] as [String: Any])

        apiClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": ["redirectUrl": "https://www.paypal.com/checkout?token=fake-ec-token"]
        ])

        let payPalNativeCheckoutClient = BTPayPalNativeCheckoutClient(apiClient: apiClient, nativeCheckoutProvider: mockNativeCheckoutProvider)
        let request = BTPayPalNativeCheckoutRequest(amount: "1.99")
        payPalNativeCheckoutClient.tokenize(request) { _, _ in }
        mockNativeCheckoutProvider.triggerApprove(returnURL: "https://fake-return-url")

        XCTAssertTrue(mockNativeCheckoutProvider.didApprove)
    }

    func testTokenize_whenOnStartableCancel_returnsCancel() async {
        apiClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "environment": "sandbox",
            "paypal": ["clientId": "a-fake-client-id"] as [String: Any?]
        ] as [String: Any])

        apiClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": ["redirectUrl": "https://www.paypal.com/checkout?token=fake-ec-token"]
        ])

        let payPalNativeCheckoutClient = BTPayPalNativeCheckoutClient(apiClient: apiClient, nativeCheckoutProvider: mockNativeCheckoutProvider)
        let request = BTPayPalNativeCheckoutRequest(amount: "1.99")
        payPalNativeCheckoutClient.tokenize(request) { _, _ in }
        mockNativeCheckoutProvider.triggerCancel()
        XCTAssertTrue(mockNativeCheckoutProvider.didCancel)

    }

    func testTokenize_whenOnStartableErrorCalled_returnsError() {
        apiClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "environment": "sandbox",
            "paypal": ["clientId": "a-fake-client-id"] as [String: Any?]
        ] as [String: Any])

        let payPalNativeCheckoutClient = BTPayPalNativeCheckoutClient(apiClient: apiClient, nativeCheckoutProvider: mockNativeCheckoutProvider)
        let request = BTPayPalNativeCheckoutRequest(amount: "1.99")
        payPalNativeCheckoutClient.tokenize(request) { _, error in
            self.mockNativeCheckoutProvider.triggerError(error: error as! BTPayPalNativeCheckoutError)
        }

        XCTAssertTrue(mockNativeCheckoutProvider.didError)
    }
}
