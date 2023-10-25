import XCTest
import PassKit
@testable import BraintreeCore
@testable import BraintreeApplePay

class BraintreeApplePay_IntegrationTests: XCTestCase {

    func testTokenizeApplePayPayment_whenApplePayEnabledInControlPanel_returnsANonce() {
        let apiClient = BTAPIClient(authorization: BTIntegrationTestsConstants.sandboxTokenizationKey)!
        let applePayClient = BTApplePayClient(apiClient: apiClient)
        let expectation = expectation(description: "Tokenize Apple Pay payment")

        applePayClient.tokenize(PKPayment()) { nonce, error in
            guard let nonce = nonce?.nonce else {
                XCTFail("Nonce expected to be returned in this tests")
            }

            XCTAssertTrue(nonce.isANonce)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testTokenizeApplePayPayment_whenApplePayDisabledInControlPanel_returnsError() {
        let apiClient = BTAPIClient(authorization: BTIntegrationTestsConstants.sandboxTokenizationKeyApplePayDisabled)!
        let applePayClient = BTApplePayClient(apiClient: apiClient)
        let expectation = expectation(description: "Tokenize Apple Pay payment")

        applePayClient.tokenize(PKPayment()) { nonce, error in
            guard let error = error as? NSError else {
                XCTFail("Error expected to be returned in this tests")
            }

            XCTAssertNil(nonce)
            XCTAssertEqual(error.domain, "com.braintreepayments.BTApplePayErrorDomain")
            XCTAssertEqual(error.code, 1)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }
}
