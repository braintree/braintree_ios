import UIKit
import XCTest
import BraintreeCard
import BraintreeVenmo

class FakeApplication {
    var lastOpenURL : NSURL? = nil
    var openURLWasCalled : Bool = false
    var cannedOpenURLSuccess : Bool = true
    var cannedCanOpenURL : Bool = true

    @objc func openURL(url: NSURL) -> Bool {
        lastOpenURL = url
        openURLWasCalled = true
        return cannedOpenURLSuccess
    }

    @objc func canOpenURL(url: NSURL) -> Bool {
        return cannedCanOpenURL
    }
}

class FakeBundle : NSBundle {
    override func objectForInfoDictionaryKey(key: String) -> AnyObject? {
        return "An App";
    }
}

class BTVenmoDriver_Tests: XCTestCase {
    var mockAPIClient : MockAPIClient = MockAPIClient(clientKey: "development_client_key")!

    override func setUp() {
        super.setUp()

        mockAPIClient = MockAPIClient(clientKey: "development_client_key")!
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testTokenization_whenRemoteConfigurationFetchFails_callsBackWithConfigurationError() {
        mockAPIClient.cannedConfigurationResponseError = NSError(domain: "", code: 0, userInfo: nil)
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"

        let expectation = self.expectationWithDescription("Tokenize fails with error")
        venmoDriver.tokenizeVenmoCardWithCompletion { (tokenizedCard, error) -> Void in
            XCTAssertEqual(error!, self.mockAPIClient.cannedConfigurationResponseError!)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testTokenization_whenVenmoConfigurationDisabled_callsBackWithError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [ "venmo": "off" ])
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"

        let expectation = expectationWithDescription("tokenization callback")
        venmoDriver.tokenizeVenmoCardWithCompletion { (tokenizedCard, error) -> Void in
            XCTAssertEqual(error!.domain, BTVenmoDriverErrorDomain)
            XCTAssertEqual(error!.code, BTVenmoDriverErrorType.Disabled.rawValue)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testTokenization_whenVenmoConfigurationMissing_callsBackWithError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [:])
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"

        let expectation = expectationWithDescription("tokenization callback")
        venmoDriver.tokenizeVenmoCardWithCompletion { (tokenizedCard, error) -> Void in
            XCTAssertEqual(error!.domain, BTVenmoDriverErrorDomain)
            XCTAssertEqual(error!.code, BTVenmoDriverErrorType.Disabled.rawValue)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testTokenization_whenVenmoIsConfiguredCorrectly_opensVenmoURL() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "venmo": "production",
            "merchantId": "merchant_id" ])
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoDriver.application = fakeApplication
        venmoDriver.bundle = FakeBundle()

        venmoDriver.tokenizeVenmoCardWithCompletion { _ -> Void in }

        XCTAssertTrue(fakeApplication.openURLWasCalled)
    }

    func testTokenization_beforeAppSwitch_informsDelegate() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "venmo": "production",
            "merchantId": "merchant_id" ])
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        let delegate = MockPaymentDriverDelegate(willPerform: expectationWithDescription("willPerform called"), didPerform: expectationWithDescription("didPerform called"))
        venmoDriver.delegate = delegate
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoDriver.application = fakeApplication
        venmoDriver.bundle = FakeBundle()

        venmoDriver.tokenizeVenmoCardWithCompletion { _ -> Void in
            XCTAssertEqual(delegate.lastPaymentDriver as? BTVenmoDriver, venmoDriver)
        }

        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testTokenization_whenUsingClientKeyAndAppSwitchSucceeds_tokenizesVenmoCard() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "venmo": "production",
            "merchantId": "merchant_id" ])
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        mockAPIClient = venmoDriver.apiClient as! MockAPIClient
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()

        let expectation = self.expectationWithDescription("Callback")
        venmoDriver.tokenizeVenmoCardWithCompletion { (tokenizedCard, error) -> Void in
            guard let tokenizedCard = tokenizedCard else {
                XCTFail("Received an error: \(error)")
                return
            }

            XCTAssertNil(error)
            XCTAssertEqual(tokenizedCard.paymentMethodNonce, "fake-nonce")
            XCTAssertEqual(tokenizedCard.localizedDescription, "Card from Venmo")
            XCTAssertNil(tokenizedCard.lastTwo)
            XCTAssertEqual(tokenizedCard.cardNetwork, BTCardNetwork.Unknown)
            expectation.fulfill()
        }
        BTVenmoDriver.handleAppSwitchReturnURL(NSURL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce")!)

        self.waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testTokenization_whenUsingJWTAndAppSwitchSucceeds_tokenizesVenmoCard() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "venmo": "production",
            "merchantId": "merchant_id" ])
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentMethods": [
                [
                    "nonce": "fake-nonce",
                    "description": "Visa ending in 11",
                    "details": [
                        "lastTwo" : "11",
                        "cardType": "visa"
                        ]
                ] ] ])
        mockAPIClient.clientJWT = "some-fake-JWT" // TODO: fix
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        mockAPIClient = venmoDriver.apiClient as! MockAPIClient
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()

        let expectation = self.expectationWithDescription("Callback")
        venmoDriver.tokenizeVenmoCardWithCompletion { (tokenizedCard, error) -> Void in
            guard let tokenizedCard = tokenizedCard else {
                XCTFail("Received an error: \(error)")
                return
            }

            XCTAssertNil(error)
            XCTAssertEqual(tokenizedCard.paymentMethodNonce, "fake-nonce")
            XCTAssertEqual(tokenizedCard.localizedDescription, "Visa ending in 11")
            XCTAssertEqual(tokenizedCard.lastTwo!, "11")
            XCTAssertEqual(tokenizedCard.cardNetwork, BTCardNetwork.Visa)
            expectation.fulfill()
        }
        BTVenmoDriver.handleAppSwitchReturnURL(NSURL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce")!)

        self.waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testTokenization_whenAppSwitchSucceeds_informsDelegate() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "venmo": "production",
            "merchantId": "merchant_id" ])
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        let delegate = MockPaymentDriverDelegate()
        delegate.willProcess = expectationWithDescription("willProcess called")
        venmoDriver.delegate = delegate
        mockAPIClient = venmoDriver.apiClient as! MockAPIClient
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()

        let expectation = self.expectationWithDescription("Callback")
        venmoDriver.tokenizeVenmoCardWithCompletion { _ -> Void in
            XCTAssertEqual(delegate.lastPaymentDriver as? BTVenmoDriver, venmoDriver)
            expectation.fulfill()
        }
        BTVenmoDriver.handleAppSwitchReturnURL(NSURL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce")!)

        self.waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testTokenization_whenAppSwitchFails_callsBackWithError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "venmo": "production",
            "merchantId": "merchant_id" ])
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        mockAPIClient = venmoDriver.apiClient as! MockAPIClient
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()

        let expectation = self.expectationWithDescription("Callback invoked")
        venmoDriver.tokenizeVenmoCardWithCompletion { (tokenizedCard, error) -> Void in
            guard let error = error else {
                XCTFail("Did not receive expected error")
                return
            }

            XCTAssertNil(tokenizedCard)
            XCTAssertEqual(error.domain, BTVenmoDriverErrorDomain)
            XCTAssertEqual(error.code, BTVenmoDriverErrorType.AppSwitchFailed.rawValue)
            expectation.fulfill()
        }
        BTVenmoDriver.handleAppSwitchReturnURL(NSURL(string: "scheme://x-callback-url/vzero/auth/venmo/error")!)

        self.waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testTokenization_whenAppSwitchCancelled_callsBackWithNoError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "venmo": "production",
            "merchantId": "merchant_id" ])
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        mockAPIClient = venmoDriver.apiClient as! MockAPIClient
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()

        let expectation = self.expectationWithDescription("Callback invoked")
        venmoDriver.tokenizeVenmoCardWithCompletion { (tokenizedCard, error) -> Void in
            XCTAssertNil(tokenizedCard)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        BTVenmoDriver.handleAppSwitchReturnURL(NSURL(string: "scheme://x-callback-url/vzero/auth/venmo/cancel")!)

        self.waitForExpectationsWithTimeout(2, handler: nil)
    }
}
