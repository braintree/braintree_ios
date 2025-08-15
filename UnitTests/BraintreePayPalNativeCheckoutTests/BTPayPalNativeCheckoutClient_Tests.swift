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

    func testUserAuthenticationIsNil_returnsNilForEmail() async {
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
        let request = BTPayPalNativeVaultRequest()
        payPalNativeCheckoutClient.tokenize(request) { _, _ in }
        mockNativeCheckoutProvider.triggerApprove(returnURL: "https://fake-return-url")

        XCTAssertTrue(mockNativeCheckoutProvider.didApprove)
    }

    func testTokenize_whenOnStartableCancel_returnsCancel() {
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
            XCTAssertEqual((error as! BTPayPalNativeCheckoutError).errorDescription, "Failed to create PayPal order: Invalid JSON response.")
        }
    }

    func testTokenize_whenInvalidRedirectURL_returnsError() {
        apiClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "environment": "sandbox",
            "paypal": ["clientId": "a-fake-client-id"] as [String: Any?]
        ] as [String: Any])

        apiClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": ["redirectUrl": "not-a-url"]
        ])

        let payPalNativeCheckoutClient = BTPayPalNativeCheckoutClient(apiClient: apiClient)
        let request = BTPayPalNativeCheckoutRequest(amount: "1.99")
        let expectation = expectation(description: "Checkout fails with error")

        payPalNativeCheckoutClient.tokenize(request) { nonce, error in
            guard let error = error as NSError? else { XCTFail(); return }
            XCTAssertNil(nonce)
            XCTAssertEqual(error.domain, "com.braintreepayments.BTPaypalNativeCheckoutErrorDomain")
            XCTAssertEqual(error.code, 5)
            XCTAssertEqual(error.localizedDescription, "Failed to create PayPal order: Invalid JSON response.")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testTokenize_whenInvalidConfiguration_returnsError() {
        apiClient.cannedConfigurationResponseBody = nil

        let request = BTPayPalNativeCheckoutRequest(amount: "1")
        let payPalNativeCheckoutClient = BTPayPalNativeCheckoutClient(apiClient: apiClient)
        let expectation = expectation(description: "Checkout fails with error")

        payPalNativeCheckoutClient.tokenize(request) { nonce, error in
            guard let error = error as NSError? else { XCTFail(); return }
            XCTAssertNil(nonce)
            XCTAssertEqual(error.domain, "com.braintreepayments.BTPaypalNativeCheckoutErrorDomain")
            XCTAssertEqual(error.code, 1)
            XCTAssertEqual(error.localizedDescription, "Failed to fetch Braintree configuration.")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testTokenize_whenPayPalNotEnabled_returnsError() async {
        apiClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": false,
            "environment": "sandbox",
            "paypal": ["clientId": "a-fake-client-id"] as [String: Any?]
        ] as [String: Any])

        let request = BTPayPalNativeVaultRequest()
        let payPalNativeCheckoutClient = BTPayPalNativeCheckoutClient(apiClient: apiClient)

        do {
            let _ = try await payPalNativeCheckoutClient.tokenize(request)
        } catch {
            guard let error = error as NSError? else { XCTFail(); return }
            XCTAssertEqual(error.domain, "com.braintreepayments.BTPaypalNativeCheckoutErrorDomain")
            XCTAssertEqual(error.code, 2)
            XCTAssertEqual(error.localizedDescription, "PayPal is not enabled for this merchant in the Braintree Control Panel.")
        }
    }

    func testTokenize_whenInvalidEnvironment_returnsError() async {
        apiClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "environment": "bogus",
            "paypal": ["clientId": "a-fake-client-id"] as [String: Any?]
        ] as [String: Any])

        let request = BTPayPalNativeCheckoutRequest(amount: "1")
        let payPalNativeCheckoutClient = BTPayPalNativeCheckoutClient(apiClient: apiClient)

        do {
            let _ = try await payPalNativeCheckoutClient.tokenize(request)
        } catch {
            guard let error = error as NSError? else { XCTFail(); return }
            XCTAssertEqual(error.domain, "com.braintreepayments.BTPaypalNativeCheckoutErrorDomain")
            XCTAssertEqual(error.code, 4)
            XCTAssertEqual(error.localizedDescription, "Invalid environment identifier found in the Braintree configuration.")
        }
    }

    func testTokenize_whenOrderIDIsReturned_sendsContextIDInAnalytics() {
        apiClient.cannedConfigurationResponseBody = BTJSON(
            value: [
                "paypalEnabled": true,
                "environment": "sandbox",
                "paypal": ["clientId": "a-fake-client-id"] as [String: Any?]
            ] as [String: Any]
        )

        apiClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": ["redirectUrl": "https://www.paypal.com/checkout?token=fake-ec-token"]
        ])

        let payPalNativeCheckoutClient = BTPayPalNativeCheckoutClient(apiClient: apiClient)
        let request = BTPayPalNativeVaultRequest()
        
        payPalNativeCheckoutClient.tokenize(request) { _, _ in }
        mockNativeCheckoutProvider.triggerApprove(returnURL: "https://fake-return-url")

        XCTAssertEqual(apiClient.postedContextID, "fake-ec-token")
    }

    func testTokenize_whenOrderIDIsNotReturned_doesNotSendContextIDInAnalytics() {
        apiClient.cannedConfigurationResponseBody = BTJSON(
            value: [
                "paypalEnabled": true,
                "environment": "sandbox",
                "paypal": ["clientId": "a-fake-client-id"] as [String: Any?]
            ] as [String: Any]
        )

        apiClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": ["redirectUrl": "https://www.paypal.com/checkout?token="]
        ])

        let payPalNativeCheckoutClient = BTPayPalNativeCheckoutClient(apiClient: apiClient)
        let request = BTPayPalNativeVaultRequest()

        payPalNativeCheckoutClient.tokenize(request) { _, _ in }
        mockNativeCheckoutProvider.triggerApprove(returnURL: "https://fake-return-url")

        XCTAssertNil(apiClient.postedContextID)
    }
}
