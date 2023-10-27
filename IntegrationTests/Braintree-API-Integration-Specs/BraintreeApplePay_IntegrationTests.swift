import XCTest
import PassKit
@testable import BraintreeCore
@testable import BraintreeApplePay

class BraintreeApplePay_IntegrationTests: XCTestCase {

    func testTokenizeApplePayPayment_whenApplePayEnabledInControlPanel_returnsANonce() {
        let apiClient = BTAPIClient(authorization: BTIntegrationTestsConstants.sandboxTokenizationKey)!
        let applePayClient = BTApplePayClient(apiClient: apiClient)
        let expectation = expectation(description: "Tokenize Apple Pay payment")

        applePayClient.tokenize(PKPayment()) { tokenizedApplePayAccount, error in
            guard let nonce = tokenizedApplePayAccount?.nonce else {
                XCTFail("Nonce expected to be returned in this tests")
                return
            }

            XCTAssertTrue(nonce.isValidNonce)
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
                return
            }

            XCTAssertNil(nonce)
            XCTAssertEqual(error.domain, BTApplePayError.errorDomain)
            XCTAssertEqual(error.code, BTApplePayError.unsupported.errorCode)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }
}
