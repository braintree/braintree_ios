import XCTest
@testable import BraintreePayPalNativeCheckout
@testable import BraintreeCore

import BraintreeTestShared

class BTPayPalNativeOrderCreationClient_Tests: XCTestCase {
    var apiClient: MockAPIClient!
    var orderCreationClient: BTPayPalNativeOrderCreationClient!
    let request = BTPayPalNativeCheckoutRequest(amount: "10.00")

    override func setUp() {
        super.setUp()
        apiClient = MockAPIClient(authorization: "development_client_key")
        orderCreationClient = BTPayPalNativeOrderCreationClient(with: apiClient)
    }

    func testCreateOrderSuccess()  {
        let environment = "sandbox"
        let clientId = "someClientId"
        let orderId = "someOrderId"

        apiClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "environment": environment,
            "paypal": ["clientId": clientId]
        ])

        apiClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": [
                "authenticateUrl": nil,
                "intent": "authorize",
                "paymentToken": "somePayToken",
                "redirectUrl": "https://www.sandbox.paypal.com/checkoutnow?nolegacy=1&token=\(orderId)"
            ]
        ])

        orderCreationClient.createOrder(with: request) { result in
            switch result {
            case .success(let order):
                XCTAssertEqual(order.payPalClientID, clientId)
                XCTAssertEqual(order.environment.name, environment)
                XCTAssertEqual(order.orderID, orderId)
                XCTAssertEqual(self.apiClient.postedAnalyticsEvents.last, "ios.paypal-native.create-order.succeeded")

            case .failure:
                XCTFail("No error should be thrown")
            }
        }
    }

    //MARK: Failure cases

    func testCreateOrder_NoConfiguration_ThrowsConfigurationError() {
        apiClient.cannedConfigurationResponseBody = nil

        orderCreationClient.createOrder(with: request) { result in
            switch result {
            case .success:
                XCTFail("Error should be thrown due to lack of configuration")

            case .failure(let error):
                XCTAssertEqual(error, .fetchConfigurationFailed)
            }
        }
    }

    func testCreateOrder_PayPalDisabled_ThrowsDisabledError() {
        apiClient.cannedConfigurationResponseBody = BTJSON(value: ["paypalEnabled": false])

        orderCreationClient.createOrder(with: request) { result in
            switch result {
            case .success:
                XCTFail("Configuration should result in paypal being disabled")

            case .failure(let error):
                XCTAssertEqual(error, .payPalNotEnabled)
                XCTAssertEqual(self.apiClient.postedAnalyticsEvents.last, "ios.paypal-native.create-order.paypal-not-enabled.failed")
            }
        }
    }

    func testCreateOrder_NoClientID_ThrowsClientIDError() {
        apiClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "paypal": ["clientId": nil]
        ])

        orderCreationClient.createOrder(with: request) { result in
            switch result {
            case .success:
                XCTFail("Configuration state should throw a client id error")

            case .failure(let error):
                XCTAssertEqual(error, .payPalClientIDNotFound)
                XCTAssertEqual(self.apiClient.postedAnalyticsEvents.last, "ios.paypal-native.create-order.client-id-not-found.failed")
            }
        }
    }

    func testCreateOrder_BadEnvironment_ThrowsEnvironmentError() {
        apiClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "environment": "staging",
            "paypal": ["clientId": "12345"]
        ])

        orderCreationClient.createOrder(with: request) { result in
            switch result {
            case .success:
                XCTFail("Configuration state should throw an invalid environment error")

            case .failure(let error):
                XCTAssertEqual(error, .invalidEnvironment)
                XCTAssertEqual(self.apiClient.postedAnalyticsEvents.last, "ios.paypal-native.create-order.invalid-environment.failed")
            }
        }
    }

    func testCreateOrder_NoHermesResponse_ThrowsOrderCreationFailure() {
        apiClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "environment": "sandbox",
            "paypal": ["clientId": "12345"]
        ])
        apiClient.cannedResponseBody = nil

        orderCreationClient.createOrder(with: request) { result in
            switch result {
            case .success:
                XCTFail("No hermes response should result in a thrown error")

            case .failure(let error):
                XCTAssertEqual(error, .orderCreationFailed(BTPayPalNativeError.invalidJSONResponse))
                XCTAssertEqual(self.apiClient.postedAnalyticsEvents.last, "ios.paypal-native.create-order.hermes-url-request.failed")
            }
        }
    }
}
