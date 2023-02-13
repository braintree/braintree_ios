import XCTest
@testable import BraintreeCore
@testable import BraintreePayPal

class BraintreePayPal_IntegrationTests: XCTestCase {
    
    let oneTouchCoreAppSwitchSuccessURLFixture = """
        com.braintreepayments.Demo.payments://onetouch/v1/success?payload=eyJ2ZXJzaW9uIjoyLCJhY2NvdW50X2NvdW50cnkiOiJVUyIsInJlc3B\
        vbnNlX3R5cGUiOiJjb2RlIiwiZW52aXJvbm1lbnQiOiJtb2NrIiwiZXhwaXJlc19pbiI6LTEsImRpc3BsYXlfbmFtZSI6Im1vY2tEaXNwbGF5TmFtZSIsInNj\
        b3BlIjoiaHR0cHM6XC9cL3VyaS5wYXlwYWwuY29tXC9zZXJ2aWNlc1wvcGF5bWVudHNcL2Z1dHVyZXBheW1lbnRzIiwiZW1haWwiOiJtb2NrZW1haWxhZGRyZ\
        XNzQG1vY2suY29tIiwiYXV0aG9yaXphdGlvbl9jb2RlIjoibW9ja1RoaXJkUGFydHlBdXRob3JpemF0aW9uQ29kZSJ9&\
        x-source=com.paypal.ppclient.touch.v1-or-v2
        """
    let sandboxTokenizationKey = "sandbox_9dbg82cq_dcpspy2brwdjr3qn"
    let sandboxTokenizationKeyApplePayDisabled = "sandbox_g42y39zw_348pk9cgf3bgyw2b"
    let sandboxClientToken = """
        eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiI4MTUzNjg2M2ViY2Q2MWUyZTVkYjE1NjJiMGI5ZjkxNzM3YTQ2YjE1OWNmNTdjZTU2\
        ZmVlZmE1OGNhOWEyZGEwfGNyZWF0ZWRfYXQ9MjAxNS0xMi0xNFQxODozMzowOS4wNzAyODE0NDQrMDAwMFx1MDAyNm1lcmNoYW50X2lkPTM0OHBrOWNnZjNi\
        Z3l3MmJcdTAwMjZwdWJsaWNfa2V5PTJuMjQ3ZHY4OWJxOXZtcHIiLCJjb25maWdVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXku\
        Y29tOjQ0My9tZXJjaGFudHMvMzQ4cGs5Y2dmM2JneXcyYi9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24iLCJjaGFsbGVuZ2VzIjpbXSwiZW52aXJvbm1l\
        bnQiOiJzYW5kYm94IiwiY2xpZW50QXBpVXJsIjoiaHR0cHM6Ly9hcGkuc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbTo0NDMvbWVyY2hhbnRzLzM0OHBr\
        OWNnZjNiZ3l3MmIvY2xpZW50X2FwaSIsImFzc2V0c1VybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXV0aFVybCI6Imh0dHBz\
        Oi8vYXV0aC52ZW5tby5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwiYW5hbHl0aWNzIjp7InVybCI6Imh0dHBzOi8vY2xpZW50LWFuYWx5dGljcy5z\
        YW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIn0sInRocmVlRFNlY3VyZUVuYWJsZWQiOnRydWUsInRocmVlRFNlY3VyZSI6eyJsb29rdXBVcmwiOiJodHRw\
        czovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvMzQ4cGs5Y2dmM2JneXcyYi90aHJlZV9kX3NlY3VyZS9sb29rdXAi\
        fSwicGF5cGFsRW5hYmxlZCI6dHJ1ZSwicGF5cGFsIjp7ImRpc3BsYXlOYW1lIjoiQWNtZSBXaWRnZXRzLCBMdGQuIChTYW5kYm94KSIsImNsaWVudElkIjpu\
        dWxsLCJwcml2YWN5VXJsIjoiaHR0cDovL2V4YW1wbGUuY29tL3BwIiwidXNlckFncmVlbWVudFVybCI6Imh0dHA6Ly9leGFtcGxlLmNvbS90b3MiLCJiYXNl\
        VXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhc3NldHNVcmwiOiJodHRwczovL2NoZWNrb3V0LnBheXBhbC5jb20iLCJkaXJl\
        Y3RCYXNlVXJsIjpudWxsLCJhbGxvd0h0dHAiOnRydWUsImVudmlyb25tZW50Tm9OZXR3b3JrIjp0cnVlLCJlbnZpcm9ubWVudCI6Im9mZmxpbmUiLCJ1bnZl\
        dHRlZE1lcmNoYW50IjpmYWxzZSwiYnJhaW50cmVlQ2xpZW50SWQiOiJtYXN0ZXJjbGllbnQzIiwiYmlsbGluZ0FncmVlbWVudHNFbmFibGVkIjp0cnVlLCJt\
        ZXJjaGFudEFjY291bnRJZCI6ImFjbWV3aWRnZXRzbHRkc2FuZGJveCIsImN1cnJlbmN5SXNvQ29kZSI6IlVTRCJ9LCJjb2luYmFzZUVuYWJsZWQiOmZhbHNl\
        LCJtZXJjaGFudElkIjoiMzQ4cGs5Y2dmM2JneXcyYiIsInZlbm1vIjoib2ZmIn0=
        """
    let sandboxClientTokenVersion3 = """
        eyJ2ZXJzaW9uIjozLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiIxYzM5N2E5OGZmZGRkNDQwM2VjNzEzYWRjZTI3NTNiMzJlODc2MzBiY2YyN2M3NmM2\
        OWVmZjlkMTE5MjljOTVkfGNyZWF0ZWRfYXQ9MjAxNy0wNC0wNVQwNjowNzowOC44MTUwOTkzMjUrMDAwMFx1MDAyNm1lcmNoYW50X2lkPWRjcHNweTJicndk\
        anIzcW5cdTAwMjZwdWJsaWNfa2V5PTl3d3J6cWszdnIzdDRuYzgiLCJjb25maWdVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXku\
        Y29tOjQ0My9tZXJjaGFudHMvZGNwc3B5MmJyd2RqcjNxbi9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24ifQ==
        """
    
    // MARK: - Checkout Flow Tests
    
    func testCheckoutFlow_withTokenizationKey_tokenizesPayPalAccount() {
        guard let apiClient = BTAPIClient(authorization: sandboxTokenizationKey) else {
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
        guard let apiClient = BTAPIClient(authorization: sandboxClientToken) else {
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
        guard let apiClient = BTAPIClient(authorization: sandboxTokenizationKey) else {
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
        guard let apiClient = BTAPIClient(authorization: sandboxClientToken) else {
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
