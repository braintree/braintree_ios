//
//  BTPayPalNativeCheckoutClient_Tests.swift
//  BraintreePayPalNativeCheckoutTests
//
//  Created by Jones, Jon on 6/29/22.
//

import XCTest
import BraintreeTestShared
@testable import BraintreePayPalNativeCheckout
@testable import BraintreeCore
@testable import BraintreePayPal

class BTPayPalNativeCheckoutClient_Tests: XCTestCase {
    var apiClient: MockAPIClient!

    override func setUp() {
        super.setUp()
        apiClient = MockAPIClient(authorization: "development_client_key")
    }

    func testInvalidRequest_ReturnsCorrectError() {
        let checkoutClient = BTPayPalNativeCheckoutClient(apiClient: apiClient)

        checkoutClient.tokenizePayPalAccount(with: BTPayPalRequest()) { nonce, error in
            XCTAssertNil(nonce)
            XCTAssertEqual(error as? BTPayPalNativeError, .invalidRequest)
        }
    }

    func testInvalidConfiguration_ReturnsCorrectError() {
        let environment = "sandbox"
        apiClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "environment": environment,
            "paypal": ["clientId": nil]
        ])

        let nativeCheckoutRequest = BTPayPalNativeCheckoutRequest(amount: "4.30")
        let checkoutClient = BTPayPalNativeCheckoutClient(apiClient: apiClient)
        checkoutClient.tokenizePayPalAccount(with: nativeCheckoutRequest) { nonce, error in
            XCTAssertNil(nonce)
            XCTAssertEqual(error as? BTPayPalNativeError, .payPalClientIDNotFound)
        }
    }
}
