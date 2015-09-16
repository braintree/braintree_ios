import BraintreeCard
import BraintreeCore
import BraintreePayPal
import BraintreeUI
import BraintreeVenmo
import XCTest

class Braintree_Tests: XCTestCase {
    
    let ValidClientToken = "eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiI3ODJhZmFlNDJlZTNiNTA4NWUxNmMzYjhkZTY3OGQxNTJhODFlYzk5MTBmZDNhY2YyYWU4MzA2OGI4NzE4YWZhfGNyZWF0ZWRfYXQ9MjAxNS0wOC0yMFQwMjoxMTo1Ni4yMTY1NDEwNjErMDAwMFx1MDAyNmN1c3RvbWVyX2lkPTM3OTU5QTE5LThCMjktNDVBNC1CNTA3LTRFQUNBM0VBOEM4Nlx1MDAyNm1lcmNoYW50X2lkPWRjcHNweTJicndkanIzcW5cdTAwMjZwdWJsaWNfa2V5PTl3d3J6cWszdnIzdDRuYzgiLCJjb25maWdVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvZGNwc3B5MmJyd2RqcjNxbi9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24iLCJjaGFsbGVuZ2VzIjpbXSwiZW52aXJvbm1lbnQiOiJzYW5kYm94IiwiY2xpZW50QXBpVXJsIjoiaHR0cHM6Ly9hcGkuc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbTo0NDMvbWVyY2hhbnRzL2RjcHNweTJicndkanIzcW4vY2xpZW50X2FwaSIsImFzc2V0c1VybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXV0aFVybCI6Imh0dHBzOi8vYXV0aC52ZW5tby5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwiYW5hbHl0aWNzIjp7InVybCI6Imh0dHBzOi8vY2xpZW50LWFuYWx5dGljcy5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIn0sInRocmVlRFNlY3VyZUVuYWJsZWQiOnRydWUsInRocmVlRFNlY3VyZSI6eyJsb29rdXBVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvZGNwc3B5MmJyd2RqcjNxbi90aHJlZV9kX3NlY3VyZS9sb29rdXAifSwicGF5cGFsRW5hYmxlZCI6dHJ1ZSwicGF5cGFsIjp7ImRpc3BsYXlOYW1lIjoiQWNtZSBXaWRnZXRzLCBMdGQuIChTYW5kYm94KSIsImNsaWVudElkIjpudWxsLCJwcml2YWN5VXJsIjoiaHR0cDovL2V4YW1wbGUuY29tL3BwIiwidXNlckFncmVlbWVudFVybCI6Imh0dHA6Ly9leGFtcGxlLmNvbS90b3MiLCJiYXNlVXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhc3NldHNVcmwiOiJodHRwczovL2NoZWNrb3V0LnBheXBhbC5jb20iLCJkaXJlY3RCYXNlVXJsIjpudWxsLCJhbGxvd0h0dHAiOnRydWUsImVudmlyb25tZW50Tm9OZXR3b3JrIjp0cnVlLCJlbnZpcm9ubWVudCI6Im9mZmxpbmUiLCJ1bnZldHRlZE1lcmNoYW50IjpmYWxzZSwiYnJhaW50cmVlQ2xpZW50SWQiOiJtYXN0ZXJjbGllbnQzIiwiYmlsbGluZ0FncmVlbWVudHNFbmFibGVkIjpmYWxzZSwibWVyY2hhbnRBY2NvdW50SWQiOiJzdGNoMm5mZGZ3c3p5dHc1IiwiY3VycmVuY3lJc29Db2RlIjoiVVNEIn0sImNvaW5iYXNlRW5hYmxlZCI6dHJ1ZSwiY29pbmJhc2UiOnsiY2xpZW50SWQiOiIxMWQyNzIyOWJhNThiNTZkN2UzYzAxYTA1MjdmNGQ1YjQ0NmQ0ZjY4NDgxN2NiNjIzZDI1NWI1NzNhZGRjNTliIiwibWVyY2hhbnRBY2NvdW50IjoiY29pbmJhc2UtZGV2ZWxvcG1lbnQtbWVyY2hhbnRAZ2V0YnJhaW50cmVlLmNvbSIsInNjb3BlcyI6ImF1dGhvcml6YXRpb25zOmJyYWludHJlZSB1c2VyIiwicmVkaXJlY3RVcmwiOiJodHRwczovL2Fzc2V0cy5icmFpbnRyZWVnYXRld2F5LmNvbS9jb2luYmFzZS9vYXV0aC9yZWRpcmVjdC1sYW5kaW5nLmh0bWwiLCJlbnZpcm9ubWVudCI6Im1vY2sifSwibWVyY2hhbnRJZCI6ImRjcHNweTJicndkanIzcW4iLCJ2ZW5tbyI6Im9mZmxpbmUiLCJhcHBsZVBheSI6eyJzdGF0dXMiOiJtb2NrIiwiY291bnRyeUNvZGUiOiJVUyIsImN1cnJlbmN5Q29kZSI6IlVTRCIsIm1lcmNoYW50SWRlbnRpZmllciI6Im1lcmNoYW50LmNvbS5icmFpbnRyZWVwYXltZW50cy5zYW5kYm94LkJyYWludHJlZS1EZW1vIiwic3VwcG9ydGVkTmV0d29ya3MiOlsidmlzYSIsIm1hc3RlcmNhcmQiLCJhbWV4Il19fQ==";

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: BTAPIClient
    
    func testAPIClientInitialization_withValidClientKey_returnsClientWithClientKey() {
        let apiClient = Braintree.clientWithClientKey("development_testing_integration_merchant_id")
        XCTAssertEqual(apiClient?.clientKey, "development_testing_integration_merchant_id")
    }

    func testAPIClientInitialization_withInvalidClientKey_returnsNil() {
        XCTAssertNil(Braintree.clientWithClientKey("invalid"))
    }
    
    func testAPIClientInitialization_withValidClientToken_returnsClientWithClientToken() {
        let apiClient = Braintree.clientWithClientToken(ValidClientToken)
        let clientToken = try! BTClientToken(clientToken: ValidClientToken)
        XCTAssertEqual(apiClient?.clientToken, clientToken)
    }
    
    func testAPIClientInitialization_withInvalidClientToken_returnsNil() {
        XCTAssertNil(Braintree.clientWithClientToken("invalid"))
    }
    
    // MARK: BTCardClient
    
    func testCardClientInitialization_withValidClientKey_returnsClientWithClientKey() {
        let cardClient = Braintree.cardClientWithClientKey("development_testing_integration_merchant_id")
        XCTAssertEqual(cardClient?.apiClient.clientKey, "development_testing_integration_merchant_id")
    }
    
    func testCardClientInitialization_withInvalidClientKey_returnsNil() {
        XCTAssertNil(Braintree.cardClientWithClientKey("invalid"))
    }
    
    func testCardClientInitialization_withValidClientToken_returnsClientWithClientToken() {
        let cardClient = Braintree.cardClientWithClientToken(ValidClientToken)
        let clientToken = try! BTClientToken(clientToken: ValidClientToken)
        XCTAssertEqual(cardClient?.apiClient.clientToken, clientToken)
    }
    
    func testCardClientInitialization_withInvalidClientToken_returnsNil() {
        XCTAssertNil(Braintree.cardClientWithClientKey("invalid"))
    }
    
    // MARK: BTPayPalDriver
    
    func testPayPalDriverInitialization_withValidClientKey_returnsDriverWithClientKey() {
        let payPalDriver = Braintree.payPalDriverWithClientKey("development_testing_integration_merchant_id")
        XCTAssertEqual(payPalDriver?.apiClient.clientKey, "development_testing_integration_merchant_id")
    }
    
    func testPayPalDriverInitialization_withInvalidClientKey_returnsNil() {
        XCTAssertNil(Braintree.payPalDriverWithClientKey("invalid"))
    }
    
    func testPayPalDriverInitialization_withValidClientToken_returnsDriverWithClientToken() {
        let payPalDriver = Braintree.payPalDriverWithClientToken(ValidClientToken)
        let clientToken = try! BTClientToken(clientToken: ValidClientToken)
        XCTAssertEqual(payPalDriver?.apiClient.clientToken, clientToken)
    }
    
    func testPayPalDriverInitialization_withInvalidClientToken_returnsNil() {
        XCTAssertNil(Braintree.payPalDriverWithClientToken("invalid"))
    }
    
    // MARK: BTVenmoDriver
    
    func testVenmoDriverInitialization_withValidClientKey_returnsDriverWithClientKey() {
        let venmoDriver = Braintree.venmoDriverWithClientKey("development_testing_integration_merchant_id")
        XCTAssertEqual(venmoDriver?.apiClient.clientKey, "development_testing_integration_merchant_id")
    }
    
    func testVenmoDriverInitialization_withInvalidClientKey_returnsNil() {
        XCTAssertNil(Braintree.venmoDriverWithClientKey("invalid"))
    }
    
    func testVenmoDriverInitialization_withValidClientToken_returnsDriverWithClientToken() {
        let venmoDriver = Braintree.venmoDriverWithClientToken(ValidClientToken)
        let clientToken = try! BTClientToken(clientToken: ValidClientToken)
        XCTAssertEqual(venmoDriver?.apiClient.clientToken, clientToken)
    }
    
    func testVenmoDriverInitialization_withInvalidClientToken_returnsNil() {
        XCTAssertNil(Braintree.venmoDriverWithClientToken("invalid"))
    }
    
    // MARK: Apple Pay
    
    func testApplePayInitialization_withValidClientKey_returnsClientWithClientKey() {
        let applePayClient = Braintree.applePayClientWithClientKey("development_testing_integration_merchant_id")
        XCTAssertEqual(applePayClient?.apiClient.clientKey, "development_testing_integration_merchant_id")
    }
    
    func testApplePayInitialization_withInvalidClientKey_returnsNil() {
        XCTAssertNil(Braintree.applePayClientWithClientKey("invalid"))
    }
    
    func testApplePayInitialization_withValidClientToken_returnsClientWithClientToken() {
        let applePayClient = Braintree.applePayClientWithClientToken(ValidClientToken)
        let clientToken = try! BTClientToken(clientToken: ValidClientToken)
        XCTAssertEqual(applePayClient?.apiClient.clientToken, clientToken)
    }
    
    func testApplePayInitialization_withInvalidClientToken_returnsNil() {
        XCTAssertNil(Braintree.applePayClientWithClientToken("invalid"))
    }
    
    // MARK: UI
    func testDropInInitialization_withValidClientKey_returnsDropInWithClientKey() {
        let dropInViewController = Braintree.dropInViewControllerWithClientKey("development_testing_integration_merchant_id")
        XCTAssertEqual(dropInViewController?.apiClient.clientKey, "development_testing_integration_merchant_id")
    }
    
    func testDropInInitialization_withInvalidClientKey_returnsNil() {
        XCTAssertNil(Braintree.dropInViewControllerWithClientKey("invalid"))
    }
    
    func testDropInInitialization_withValidClientToken_returnsDropInWithClientToken() {
        let dropInViewController = Braintree.dropInViewControllerWithClientToken(ValidClientToken)
        let clientToken = try! BTClientToken(clientToken: ValidClientToken)
        XCTAssertEqual(dropInViewController?.apiClient.clientToken, clientToken)
    }
    
    func testDropInInitialization_withInvalidClientToken_returnsNil() {
        XCTAssertNil(Braintree.dropInViewControllerWithClientToken("invalid"))
    }
    
    func testPaymentButtonInitialization_withValidClientKey_returnsPaymentButtonWithClientKey() {
        let paymentButton = Braintree.paymentButtonWithClientKey("development_testing_integration_merchant_id")
        XCTAssertEqual(paymentButton?.apiClient.clientKey, "development_testing_integration_merchant_id")
    }
    
    func testPaymentButtonInitialization_withInvalidClientKey_returnsNil() {
        XCTAssertNil(Braintree.paymentButtonWithClientKey("invalid"))
    }
    
    func testPaymentButtonInitialization_withValidClientToken_returnsPaymentButtonWithClientToken() {
        let paymentButton = Braintree.paymentButtonWithClientToken(ValidClientToken)
        let clientToken = try! BTClientToken(clientToken: ValidClientToken)
        XCTAssertEqual(paymentButton?.apiClient.clientToken, clientToken)
    }
    
    func testPaymentButtonInitialization_withInvalidClientToken_returnsNil() {
        XCTAssertNil(Braintree.paymentButtonWithClientToken("invalid"))
    }
}
