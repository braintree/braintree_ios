import XCTest
@testable import BraintreeCore
@testable import BraintreePayPal

class BraintreePayPal_IntegrationTests: XCTestCase {
    
    let oneTouchCoreAppSwitchSuccessURLFixture = "com.braintreepayments.Demo.payments://onetouch/v1/success?payload=eyJ2ZXJzaW9uIjoyLCJhY2NvdW50X2NvdW50cnkiOiJVUyIsInJlc3BvbnNlX3R5cGUiOiJjb2RlIiwiZW52aXJvbm1lbnQiOiJtb2NrIiwiZXhwaXJlc19pbiI6LTEsImRpc3BsYXlfbmFtZSI6Im1vY2tEaXNwbGF5TmFtZSIsInNjb3BlIjoiaHR0cHM6XC9cL3VyaS5wYXlwYWwuY29tXC9zZXJ2aWNlc1wvcGF5bWVudHNcL2Z1dHVyZXBheW1lbnRzIiwiZW1haWwiOiJtb2NrZW1haWxhZGRyZXNzQG1vY2suY29tIiwiYXV0aG9yaXphdGlvbl9jb2RlIjoibW9ja1RoaXJkUGFydHlBdXRob3JpemF0aW9uQ29kZSJ9&x-source=com.paypal.ppclient.touch.v1-or-v2"
    
    let authorization: String = "sandbox_9dbg82cq_dcpspy2brwdjr3qn"

    // MARK: - Checkout Flow Tests
    
    func testCheckoutFlow_withTokenizationKey_tokenizesPayPalAccount() {        
        let payPalClient = BTPayPalClient(authorization: BTIntegrationTestsConstants.sandboxTokenizationKey)
        payPalClient.payPalRequest = BTPayPalVaultRequest()
        
        let tokenizationExpectation = expectation(description: "Tokenize one-time payment")
        let returnURL = URL(string: oneTouchCoreAppSwitchSuccessURLFixture)
        
        payPalClient.handleReturn(returnURL, paymentType: .checkout) { tokenizedPayPalAccount, error in
            guard let nonce = tokenizedPayPalAccount?.nonce else {
                XCTFail("Failed to tokenize account.")
                return
            }
            
            XCTAssertTrue(nonce.isValidNonce)
            XCTAssertNil(error)
            tokenizationExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    
    func testCheckoutFlow_withClientToken_tokenizesPayPalAccount() {
        let payPalClient = BTPayPalClient(authorization: BTIntegrationTestsConstants.sandboxClientToken)
        payPalClient.payPalRequest = BTPayPalVaultRequest()

        let tokenizationExpectation = expectation(description: "Tokenize one-time payment")
        let returnURL = URL(string: oneTouchCoreAppSwitchSuccessURLFixture)
        
        payPalClient.handleReturn(returnURL,paymentType: .checkout) { tokenizedPayPalAccount, error in
            guard let nonce = tokenizedPayPalAccount?.nonce else {
                XCTFail("Failed to tokenize account.")
                return
            }
            
            XCTAssertTrue(nonce.isValidNonce)
            XCTAssertNil(error)
            tokenizationExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    
    func testCheckoutFlow_withoutPayPalRequest_returnsError() {
        let payPalClient = BTPayPalClient(authorization: BTIntegrationTestsConstants.sandboxTokenizationKey)

        let tokenizationExpectation = expectation(description: "Tokenize one-time payment")
        let returnURL = URL(string: oneTouchCoreAppSwitchSuccessURLFixture)
        
        payPalClient.handleReturn(returnURL, paymentType: .checkout) { tokenizedPayPalAccount, error in
            XCTAssertNotNil(error)
            XCTAssertEqual(error?.localizedDescription, "The PayPal Request was missing or invalid.")
            tokenizationExpectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }
    
    // MARK: - Vault Flow Tests
    
    func testVaultFlow_withTokenizationKey_tokenizesPayPalAccount() {
        let payPalClient = BTPayPalClient(authorization: BTIntegrationTestsConstants.sandboxTokenizationKey)
        payPalClient.payPalRequest = BTPayPalVaultRequest()

        let tokenizationExpectation = expectation(description: "Tokenize billing agreement payment")
        let returnURL = URL(string: oneTouchCoreAppSwitchSuccessURLFixture)
        
        payPalClient.handleReturn(returnURL, paymentType: .vault) { tokenizedPayPalAccount, error in
            guard let nonce = tokenizedPayPalAccount?.nonce else {
                XCTFail("Failed to tokenize account.")
                return
            }
            
            XCTAssertTrue(nonce.isValidNonce)
            XCTAssertNil(error)
            tokenizationExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    
    func testVaultFlow_withClientToken_tokenizedPayPalAccount() {
        let payPalClient = BTPayPalClient(authorization: BTIntegrationTestsConstants.sandboxClientToken)
        payPalClient.payPalRequest = BTPayPalVaultRequest()
        
        let tokenizationExpectation = expectation(description: "Tokenize billing agreement payment")
        let returnURL = URL(string: oneTouchCoreAppSwitchSuccessURLFixture)

        payPalClient.handleReturn(returnURL, paymentType: .vault) { tokenizedPayPalAccount, error in
            guard let nonce = tokenizedPayPalAccount?.nonce else {
                XCTFail("Failed to tokenize account.")
                return
            }

            XCTAssertTrue(nonce.isValidNonce)
            XCTAssertNil(error)
            tokenizationExpectation.fulfill()
        }

        waitForExpectations(timeout: 10)
    }
}
