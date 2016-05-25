import XCTest

class BTTokenizationService_Tests: XCTestCase {

    var tokenizationService : BTTokenizationService!

    override func setUp() {
        super.setUp()
        tokenizationService = BTTokenizationService()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testRegisterType_addsTypeToTypes() {
        tokenizationService.registerType("MyType") { _ -> Void in }
        XCTAssertTrue(tokenizationService.allTypes.contains("MyType"))
    }

    func testAllTypes_whenTypeIsNotRegistered_doesntContainType() {
        XCTAssertFalse(tokenizationService.allTypes.contains("MyType"))
    }

    func testIsTypeAvailable_whenTypeIsRegistered_isTrue() {
        tokenizationService.registerType("MyType") { _ -> Void in }
        XCTAssertTrue(tokenizationService.isTypeAvailable("MyType"))
    }

    func testIsTypeAvailable_whenTypeIsNotRegistered_returnsFalse() {
        XCTAssertFalse(tokenizationService.isTypeAvailable("MyType"))
    }

    func testTokenizeType_whenTypeIsRegistered_callsTokenizationBlock() {
        let expectation = expectationWithDescription("tokenization block called")
        tokenizationService.registerType("MyType") { _ -> Void in
            expectation.fulfill()
        }

        tokenizationService.tokenizeType("MyType", withAPIClient: BTAPIClient(authorization: "development_testing_integration_merchant_id")!) { _ -> Void in }

        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testTokenizeType_whenCalledWithOptions_callsTokenizationBlockAndPassesInOptions() {
        let expectation = expectationWithDescription("tokenization block called")
        let expectedOptions = ["Some Custom Option Key": "The Option Value"]
        tokenizationService.registerType("MyType") { (_, options, _) -> Void in
            XCTAssertEqual(options as! [String : String], expectedOptions)
            expectation.fulfill()
        }

        tokenizationService.tokenizeType("MyType", options: expectedOptions, withAPIClient:BTAPIClient(authorization: "development_testing_integration_merchant_id")!) { _ -> Void in }

        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testTokenizeType_whenTypeIsNotRegistered_returnsError() {
        let expectation = expectationWithDescription("Callback invoked")
        tokenizationService.tokenizeType("UnknownType", withAPIClient:BTAPIClient(authorization: "development_testing_integration_merchant_id")!) { nonce, error -> Void in
            XCTAssertNil(nonce)
            if let error = error {
                XCTAssertEqual(error.domain, BTTokenizationServiceErrorDomain)
                XCTAssertEqual(error.code, BTTokenizationServiceError.TypeNotRegistered.rawValue)
            } else {
                XCTFail("Should have gotten an error!")
            }
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(2, handler:nil)
    }

    // MARK: - Payment-specific tests

    func testSingleton_hasExpectedTypesAvailable() {
        let sharedService = BTTokenizationService.sharedService()

        XCTAssertTrue(sharedService.isTypeAvailable("PayPal"))
        XCTAssertTrue(sharedService.isTypeAvailable("Venmo"))
        XCTAssertTrue(sharedService.isTypeAvailable("Card"))
    }

    func testSingleton_canTokenizeCards() {
        let sharedService = BTTokenizationService.sharedService()
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2020", cvv: "123")
        let stubAPIClient = MockAPIClient(authorization: "development_fake_key")!
        stubAPIClient.cannedResponseBody = BTJSON(value: [
            "creditCards": [
                [
                    "nonce": "a-nonce",
                    "description": "A card"
                ]
            ]
        ])

        let expectation = expectationWithDescription("Card is tokenized")
        sharedService.tokenizeType("Card", options: card.parameters() as? [String : AnyObject], withAPIClient: stubAPIClient) { (cardNonce, error) -> Void in
            XCTAssertEqual(cardNonce?.nonce, "a-nonce")
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(2, handler: nil)
    }

    // This test only verifies that SFSafariViewController is presented
    func testSingleton_canAuthorizePayPalThroughSFSafariViewController() {
        if #available(iOS 9.0, *) {
            let sharedService = BTTokenizationService.sharedService()
            let stubAPIClient = MockAPIClient(authorization: "development_fake_key")!
            stubAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
                "paypalEnabled": true,
                "paypal": [
                    "environment": "offline",
                    "privacyUrl": "",
                    "userAgreementUrl": "",
                    "environment": "offline",
                ] ])
            let mockDelegate = MockViewControllerPresentationDelegate()
            BTAppSwitch.setReturnURLScheme("com.braintreepayments.Demo.payments")

            sharedService.tokenizeType("PayPal", options: [BTTokenizationServiceViewPresentingDelegateOption: mockDelegate], withAPIClient: stubAPIClient) { _ -> Void in }

            XCTAssertTrue(mockDelegate.lastViewController is SFSafariViewController)
        }
    }

    func testSingleton_canAuthorizeVenmo() {
        let sharedService = BTTokenizationService.sharedService()
        BTConfiguration.setBetaPaymentOption("venmo", isEnabled: true)
        BTOCMockHelper().stubApplicationCanOpenURL()
        BTAppSwitch.setReturnURLScheme("com.braintreepayments.Demo.payments")
        let stubAPIClient = MockAPIClient(authorization: "development_fake_key")!
        stubAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "payWithVenmo": [
                "accessToken": "fake-access-token",
                "environment": "sandbox",
                "merchantId": "stubmerchantid",
            ],
        ])
        let mockDelegate = MockAppSwitchDelegate(willPerform: expectationWithDescription("Will authorize Venmo Account"), didPerform: nil)

        sharedService.tokenizeType("Venmo", options: [BTTokenizationServiceAppSwitchDelegateOption: mockDelegate], withAPIClient: stubAPIClient) { _ -> Void in }

        waitForExpectationsWithTimeout(2, handler: nil)
    }
}
