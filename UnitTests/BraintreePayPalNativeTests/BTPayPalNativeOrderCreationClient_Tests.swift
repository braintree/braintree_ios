import XCTest
import BraintreeCore
import BraintreeTestShared

@testable import BraintreePayPalNative

class BTPayPalNativeOrderCreationClient_Tests: XCTestCase {

    private var mockAPIClient: MockAPIClient!
    private var orderCreationClient: BTPayPalNativeOrderCreationClient!

    override func setUp() {
        mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "environment": "sandbox",
            "paypalEnabled": true,
            "paypal": [
                "clientId": "some-client-id"
            ]
        ])

        orderCreationClient = BTPayPalNativeOrderCreationClient(with: mockAPIClient)
    }

    // MARK: - fetch configuration

    func testCreateOrder_whenRemoteConfigurationFetchFails_callsBackWithConfigurationError() {
        mockAPIClient.cannedConfigurationResponseBody = nil
        mockAPIClient.cannedConfigurationResponseError = NSError(domain: "", code: 0, userInfo: nil)

        let request = BTPayPalNativeCheckoutRequest(payPalReturnURL: "returnURL", amount: "1")
        let expectation = self.expectation(description: "Checkout fails with error")

        orderCreationClient.createOrder(with: request) { result in
            XCTAssertEqual(result, .failure(.fetchConfigurationFailed))
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1)
    }

    func testCreateOrder_whenConfigurationIsNil_callsBackWithError() {
        mockAPIClient.cannedConfigurationResponseBody = nil

        let request = BTPayPalNativeCheckoutRequest(payPalReturnURL: "returnURL", amount: "1")
        let expectation = self.expectation(description: "Checkout fails with error")

        orderCreationClient.createOrder(with: request) { result in
            XCTAssertEqual(result, .failure(.fetchConfigurationFailed))
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1)
    }

    func testCreateOrder_whenPayPalNotEnabledInConfiguration_callsBackWithError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": false
        ])

        let request = BTPayPalNativeCheckoutRequest(payPalReturnURL: "returnURL", amount: "1")
        let expectation = self.expectation(description: "Checkout fails with error")

        orderCreationClient.createOrder(with: request) { result in
            XCTAssertEqual(result, .failure(.payPalNotEnabled))
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1)
    }

    func testCreateOrder_whenPayPalEnabledMissingFromConfiguration_callsBackWithError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [])

        let request = BTPayPalNativeCheckoutRequest(payPalReturnURL: "returnURL", amount: "1")
        let expectation = self.expectation(description: "Checkout fails with error")

        orderCreationClient.createOrder(with: request) { result in
            XCTAssertEqual(result, .failure(.payPalNotEnabled))
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1)
    }

    func testCreateOrder_whenPayPalClientIDMissingFromConfiguration_callsBackWithError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true
        ])

        let request = BTPayPalNativeCheckoutRequest(payPalReturnURL: "returnURL", amount: "1")
        let expectation = self.expectation(description: "Checkout fails with error")

        orderCreationClient.createOrder(with: request) { result in
            XCTAssertEqual(result, .failure(.payPalClientIDNotFound))
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1)
    }

    func testCreateOrder_whenEnvironmentMissingFromConfiguration_callsBackWithError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "paypal": [
                "clientId": "some-client-id"
            ]
        ])

        let request = BTPayPalNativeCheckoutRequest(payPalReturnURL: "returnURL", amount: "1")
        let expectation = self.expectation(description: "Checkout fails with error")

        orderCreationClient.createOrder(with: request) { result in
            XCTAssertEqual(result, .failure(.invalidEnvironment))
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1)
    }

    func testCreateOrder_whenEnvironmentIsNotProdOrSandbox_callsBackWithError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "environment": "invalid-environment",
            "paypalEnabled": true,
            "paypal": [
                "clientId": "some-client-id"
            ]
        ])

        let request = BTPayPalNativeCheckoutRequest(payPalReturnURL: "returnURL", amount: "1")
        let expectation = self.expectation(description: "Checkout fails with error")

        orderCreationClient.createOrder(with: request) { result in
            XCTAssertEqual(result, .failure(.invalidEnvironment))
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1)
    }

    // MARK: - POST to Hermes

    func testCreateOrder_whenRemoteConfigurationFetchSucceeds_postsToHermesEndpoint() {
        let request = BTPayPalNativeCheckoutRequest(payPalReturnURL: "returnURL", amount: "1")
        request.intent = .sale

        orderCreationClient.createOrder(with: request) { _ in }

        XCTAssertEqual("v1/paypal_hermes/create_payment_resource", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else { XCTFail(); return }

        XCTAssertEqual(lastPostParameters["intent"] as? String, "sale")
        XCTAssertEqual(lastPostParameters["amount"] as? String, "1")
        XCTAssertEqual(lastPostParameters["return_url"] as? String, "sdk.ios.braintree://onetouch/v1/success")
        XCTAssertEqual(lastPostParameters["cancel_url"] as? String, "sdk.ios.braintree://onetouch/v1/cancel")
    }

    func testCreateOrder_whenPostToHermesFails_callsBackWithError() {
        mockAPIClient.cannedResponseError = NSError(domain: "", code: 0, userInfo: nil)

        let request = BTPayPalNativeCheckoutRequest(payPalReturnURL: "returnURL", amount: "1")
        let expectation = self.expectation(description: "Checkout fails with error")
        orderCreationClient.createOrder(with: request) { result in
            XCTAssertEqual(result, .failure(.orderCreationFailed))
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 1)
    }

    func testCreateOrder_whenHermesRespondsWithoutOrderID_callsBackWithError() {
        let jsonString =
            """
            { "unexpected": "response" }
            """
        mockAPIClient.cannedResponseBody = BTJSON(data: jsonString.data(using: .utf8)!)

        let request = BTPayPalNativeCheckoutRequest(payPalReturnURL: "returnURL", amount: "1")
        let expectation = self.expectation(description: "Checkout fails with error")
        orderCreationClient.createOrder(with: request) { result in
            XCTAssertEqual(result, .failure(.orderCreationFailed))
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 1)
    }

    func testCreateOrder_whenEnvironmentIsSand_returnsOrderWithEnvironment() {
        let jsonString =
            """
            {
                "paymentResource": {
                    "redirectUrl": "my-url.com?token=some-token"
                }
            }
            """
        mockAPIClient.cannedResponseBody = BTJSON(data: jsonString.data(using: .utf8)!)

        let expectation = self.expectation(description: "Constructs approvalURL")
        let expectedOrder = BTPayPalNativeOrder(payPalClientID: "some-client-id", environment: .sandbox, orderID: "some-token")

        let request = BTPayPalNativeCheckoutRequest(payPalReturnURL: "returnURL", amount: "12")
        orderCreationClient.createOrder(with: request) { result in
            XCTAssertEqual(result, .success(expectedOrder))
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 1)
    }

    func testCreateOrder_whenEnvironmentIsProd_returnsOrderWithEnvironment() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "environment": "production",
            "paypalEnabled": true,
            "paypal": [
                "clientId": "some-client-id"
            ]
        ])

        let jsonString =
            """
            {
                "paymentResource": {
                    "redirectUrl": "my-url.com?token=some-token"
                }
            }
            """
        mockAPIClient.cannedResponseBody = BTJSON(data: jsonString.data(using: .utf8)!)

        let expectation = self.expectation(description: "Constructs approvalURL")
        let expectedOrder = BTPayPalNativeOrder(payPalClientID: "some-client-id", environment: .live, orderID: "some-token")

        let request = BTPayPalNativeCheckoutRequest(payPalReturnURL: "returnURL", amount: "12")
        orderCreationClient.createOrder(with: request) { result in
            XCTAssertEqual(result, .success(expectedOrder))
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 1)
    }
}
