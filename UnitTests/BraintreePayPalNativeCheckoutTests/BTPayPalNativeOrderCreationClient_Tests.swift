import XCTest
@testable import BraintreeTestShared
@testable import BraintreePayPalNativeCheckout
@testable import BraintreeCore

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
        ] as [String: Any])

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
            }
        }
    }

    func testCreateOrder_NoClientID_ThrowsClientIDError() {
        apiClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "paypal": ["clientId": nil] as [String: Any?]
        ] as [String: Any])

        orderCreationClient.createOrder(with: request) { result in
            switch result {
            case .success:
                XCTFail("Configuration state should throw a client id error")

            case .failure(let error):
                XCTAssertEqual(error, .payPalClientIDNotFound)
            }
        }
    }

    func testCreateOrder_BadEnvironment_ThrowsEnvironmentError() {
        apiClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "environment": "staging",
            "paypal": ["clientId": "12345"]
        ] as [String: Any])

        orderCreationClient.createOrder(with: request) { result in
            switch result {
            case .success:
                XCTFail("Configuration state should throw an invalid environment error")

            case .failure(let error):
                XCTAssertEqual(error, .invalidEnvironment)
            }
        }
    }

    func testCreateOrder_NoHermesResponse_ThrowsOrderCreationFailure() {
        apiClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "environment": "sandbox",
            "paypal": ["clientId": "12345"]
        ] as [String: Any])
        apiClient.cannedResponseBody = nil

        orderCreationClient.createOrder(with: request) { result in
            switch result {
            case .success:
                XCTFail("No hermes response should result in a thrown error")

            case .failure(let error):
                XCTAssertEqual(error, .orderCreationFailed(BTPayPalNativeCheckoutError.invalidJSONResponse))
            }
        }
    }
}
