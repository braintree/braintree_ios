import XCTest
@testable import BraintreeCore
@testable import BraintreePayPal

class BraintreePayPal_IntegrationTests: XCTestCase {
    
    let oneTouchCoreAppSwitchSuccessURLFixture = "com.braintreepayments.Demo.payments://onetouch/v1/success?payload=eyJ2ZXJzaW9uIjoyLCJhY2NvdW50X2NvdW50cnkiOiJVUyIsInJlc3BvbnNlX3R5cGUiOiJjb2RlIiwiZW52aXJvbm1lbnQiOiJtb2NrIiwiZXhwaXJlc19pbiI6LTEsImRpc3BsYXlfbmFtZSI6Im1vY2tEaXNwbGF5TmFtZSIsInNjb3BlIjoiaHR0cHM6XC9cL3VyaS5wYXlwYWwuY29tXC9zZXJ2aWNlc1wvcGF5bWVudHNcL2Z1dHVyZXBheW1lbnRzIiwiZW1haWwiOiJtb2NrZW1haWxhZGRyZXNzQG1vY2suY29tIiwiYXV0aG9yaXphdGlvbl9jb2RlIjoibW9ja1RoaXJkUGFydHlBdXRob3JpemF0aW9uQ29kZSJ9&x-source=com.paypal.ppclient.touch.v1-or-v2"

    // MARK: - Checkout Flow Tests
    
    func testCheckoutFlow_withTokenizationKey_tokenizesPayPalAccount() {
        guard let apiClient = BTAPIClient(authorization: BTIntegrationTestsConstants.sandboxTokenizationKey) else {
            XCTFail("Failed to initialize BTAPIClient with sandbox tokenization key.")
            return
        }
        
        let payPalClient = BTPayPalClient(apiClient: apiClient)
        let tokenizationExpectation = expectation(description: "Tokenize one-time payment")
        let returnURL = URL(string: oneTouchCoreAppSwitchSuccessURLFixture)
        
        payPalClient.handleBrowserSwitchReturn(returnURL, paymentType: .checkout) { tokenizedPayPalAccount, error in
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
        guard let apiClient = BTAPIClient(authorization: BTIntegrationTestsConstants.sandboxClientToken) else {
            XCTFail("Failed to initialize BTAPIClient with sandbox tokenization key.")
            return
        }
        
        let payPalClient = BTPayPalClient(apiClient: apiClient)
        let tokenizationExpectation = expectation(description: "Tokenize one-time payment")
        let returnURL = URL(string: oneTouchCoreAppSwitchSuccessURLFixture)
        
        payPalClient.handleBrowserSwitchReturn(returnURL,paymentType: .checkout) { tokenizedPayPalAccount, error in
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
    
    // MARK: - Vault Flow Tests
    
    func testVaultFlow_withTokenizationKey_tokenizesPayPalAccount() {
        guard let apiClient = BTAPIClient(authorization: BTIntegrationTestsConstants.sandboxTokenizationKey) else {
            XCTFail("Failed to initialize BTAPIClient with sandbox tokenization key.")
            return
        }
        
        let payPalClient = BTPayPalClient(apiClient: apiClient)
        let tokenizationExpectation = expectation(description: "Tokenize billing agreement payment")
        let returnURL = URL(string: oneTouchCoreAppSwitchSuccessURLFixture)
        
        payPalClient.handleBrowserSwitchReturn(returnURL, paymentType: .vault) { tokenizedPayPalAccount, error in
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
        guard let apiClient = BTAPIClient(authorization: BTIntegrationTestsConstants.sandboxClientToken) else {
            XCTFail("Failed to initialize BTAPIClient with sandbox tokenization key.")
            return
        }
        
        let payPalClient = BTPayPalClient(apiClient: apiClient)
        let tokenizationExpectation = expectation(description: "Tokenize billing agreement payment")
        let returnURL = URL(string: oneTouchCoreAppSwitchSuccessURLFixture)
        
        payPalClient.handleBrowserSwitchReturn(returnURL, paymentType: .vault) { tokenizedPayPalAccount, error in
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
}
