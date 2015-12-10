import UIKit
import XCTest

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
    var mockAPIClient : MockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
    var observers : [NSObjectProtocol] = []
    
    let ValidClientToken = "eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiI3ODJhZmFlNDJlZTNiNTA4NWUxNmMzYjhkZTY3OGQxNTJhODFlYzk5MTBmZDNhY2YyYWU4MzA2OGI4NzE4YWZhfGNyZWF0ZWRfYXQ9MjAxNS0wOC0yMFQwMjoxMTo1Ni4yMTY1NDEwNjErMDAwMFx1MDAyNmN1c3RvbWVyX2lkPTM3OTU5QTE5LThCMjktNDVBNC1CNTA3LTRFQUNBM0VBOEM4Nlx1MDAyNm1lcmNoYW50X2lkPWRjcHNweTJicndkanIzcW5cdTAwMjZwdWJsaWNfa2V5PTl3d3J6cWszdnIzdDRuYzgiLCJjb25maWdVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvZGNwc3B5MmJyd2RqcjNxbi9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24iLCJjaGFsbGVuZ2VzIjpbXSwiZW52aXJvbm1lbnQiOiJzYW5kYm94IiwiY2xpZW50QXBpVXJsIjoiaHR0cHM6Ly9hcGkuc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbTo0NDMvbWVyY2hhbnRzL2RjcHNweTJicndkanIzcW4vY2xpZW50X2FwaSIsImFzc2V0c1VybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXV0aFVybCI6Imh0dHBzOi8vYXV0aC52ZW5tby5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwiYW5hbHl0aWNzIjp7InVybCI6Imh0dHBzOi8vY2xpZW50LWFuYWx5dGljcy5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIn0sInRocmVlRFNlY3VyZUVuYWJsZWQiOnRydWUsInRocmVlRFNlY3VyZSI6eyJsb29rdXBVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvZGNwc3B5MmJyd2RqcjNxbi90aHJlZV9kX3NlY3VyZS9sb29rdXAifSwicGF5cGFsRW5hYmxlZCI6dHJ1ZSwicGF5cGFsIjp7ImRpc3BsYXlOYW1lIjoiQWNtZSBXaWRnZXRzLCBMdGQuIChTYW5kYm94KSIsImNsaWVudElkIjpudWxsLCJwcml2YWN5VXJsIjoiaHR0cDovL2V4YW1wbGUuY29tL3BwIiwidXNlckFncmVlbWVudFVybCI6Imh0dHA6Ly9leGFtcGxlLmNvbS90b3MiLCJiYXNlVXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhc3NldHNVcmwiOiJodHRwczovL2NoZWNrb3V0LnBheXBhbC5jb20iLCJkaXJlY3RCYXNlVXJsIjpudWxsLCJhbGxvd0h0dHAiOnRydWUsImVudmlyb25tZW50Tm9OZXR3b3JrIjp0cnVlLCJlbnZpcm9ubWVudCI6Im9mZmxpbmUiLCJ1bnZldHRlZE1lcmNoYW50IjpmYWxzZSwiYnJhaW50cmVlQ2xpZW50SWQiOiJtYXN0ZXJjbGllbnQzIiwiYmlsbGluZ0FncmVlbWVudHNFbmFibGVkIjpmYWxzZSwibWVyY2hhbnRBY2NvdW50SWQiOiJzdGNoMm5mZGZ3c3p5dHc1IiwiY3VycmVuY3lJc29Db2RlIjoiVVNEIn0sImNvaW5iYXNlRW5hYmxlZCI6dHJ1ZSwiY29pbmJhc2UiOnsiY2xpZW50SWQiOiIxMWQyNzIyOWJhNThiNTZkN2UzYzAxYTA1MjdmNGQ1YjQ0NmQ0ZjY4NDgxN2NiNjIzZDI1NWI1NzNhZGRjNTliIiwibWVyY2hhbnRBY2NvdW50IjoiY29pbmJhc2UtZGV2ZWxvcG1lbnQtbWVyY2hhbnRAZ2V0YnJhaW50cmVlLmNvbSIsInNjb3BlcyI6ImF1dGhvcml6YXRpb25zOmJyYWludHJlZSB1c2VyIiwicmVkaXJlY3RVcmwiOiJodHRwczovL2Fzc2V0cy5icmFpbnRyZWVnYXRld2F5LmNvbS9jb2luYmFzZS9vYXV0aC9yZWRpcmVjdC1sYW5kaW5nLmh0bWwiLCJlbnZpcm9ubWVudCI6Im1vY2sifSwibWVyY2hhbnRJZCI6ImRjcHNweTJicndkanIzcW4iLCJ2ZW5tbyI6Im9mZmxpbmUiLCJhcHBsZVBheSI6eyJzdGF0dXMiOiJtb2NrIiwiY291bnRyeUNvZGUiOiJVUyIsImN1cnJlbmN5Q29kZSI6IlVTRCIsIm1lcmNoYW50SWRlbnRpZmllciI6Im1lcmNoYW50LmNvbS5icmFpbnRyZWVwYXltZW50cy5zYW5kYm94LkJyYWludHJlZS1EZW1vIiwic3VwcG9ydGVkTmV0d29ya3MiOlsidmlzYSIsIm1hc3RlcmNhcmQiLCJhbWV4Il19fQ==";

    override func setUp() {
        super.setUp()

        mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
    }

    override func tearDown() {
        for observer in observers { NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
        super.tearDown()
    }
    
    func testAuthorizeAccount_whenAPIClientIsNil_callsBackWithError() {
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        venmoDriver.apiClient = nil
        
        let expectation = expectationWithDescription("Callback invoked with error")
        venmoDriver.authorizeAccountWithCompletion { (tokenizedCard, error) -> Void in
            XCTAssertNil(tokenizedCard)
            XCTAssertEqual(error!.domain, BTVenmoDriverErrorDomain)
            XCTAssertEqual(error!.code, BTVenmoDriverErrorType.Integration.rawValue)
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }

    func testAuthorizeAccount_whenRemoteConfigurationFetchFails_callsBackWithConfigurationError() {
        mockAPIClient.cannedConfigurationResponseError = NSError(domain: "", code: 0, userInfo: nil)
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"

        let expectation = self.expectationWithDescription("Tokenize fails with error")
        venmoDriver.authorizeAccountWithCompletion { (tokenizedCard, error) -> Void in
            XCTAssertEqual(error!, self.mockAPIClient.cannedConfigurationResponseError!)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testAuthorizeAccount_whenVenmoConfigurationDisabled_callsBackWithError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [ "venmo": "off" ])
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"

        let expectation = expectationWithDescription("tokenization callback")
        venmoDriver.authorizeAccountWithCompletion { (tokenizedCard, error) -> Void in
            XCTAssertEqual(error!.domain, BTVenmoDriverErrorDomain)
            XCTAssertEqual(error!.code, BTVenmoDriverErrorType.Disabled.rawValue)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testAuthorizeAccount_whenVenmoConfigurationMissing_callsBackWithError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [:])
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"

        let expectation = expectationWithDescription("tokenization callback")
        venmoDriver.authorizeAccountWithCompletion { (tokenizedCard, error) -> Void in
            XCTAssertEqual(error!.domain, BTVenmoDriverErrorDomain)
            XCTAssertEqual(error!.code, BTVenmoDriverErrorType.Disabled.rawValue)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testAuthorization_whenReturnURLSchemeIsNil_logsCriticalMessageAndCallsBackWithError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["environment":"sandbox",
            "payWithVenmo" : ["accessToken" : "access-token"],
            "merchantId": "merchant_id" ])
        BTConfiguration.enableVenmo(true);
        
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        BTAppSwitch.sharedInstance().returnURLScheme = ""

        
        var criticalMessageLogged = false
        BTLogger.sharedLogger().logBlock = {
            (level: BTLogLevel, message: String!) in
            if (level == BTLogLevel.Critical && message == "Venmo requires a return URL scheme to be configured via [BTAppSwitch setReturnURLScheme:]") {
                criticalMessageLogged = true
            }
            BTLogger.sharedLogger().logBlock = nil
            return
        }
        
        let expectation = expectationWithDescription("authorization callback")
        venmoDriver.authorizeAccountWithCompletion { (venmoAccount, error) -> Void in
            XCTAssertEqual(error!.domain, BTVenmoDriverErrorDomain)
            XCTAssertEqual(error!.code, BTVenmoDriverErrorType.AppNotAvailable.rawValue)
            expectation.fulfill()
        }
        
        XCTAssertTrue(criticalMessageLogged)
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testAuthorization_whenVenmoIsEnabledInControlPanelAndConfiguredCorrectly_opensVenmoURL() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["environment":"sandbox",
            "payWithVenmo" : ["accessToken" : "access-token"],
            "merchantId": "merchant_id" ])
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoDriver.application = fakeApplication
        venmoDriver.bundle = FakeBundle()

        venmoDriver.authorizeAccountWithCompletion { _ -> Void in }

        XCTAssertTrue(fakeApplication.openURLWasCalled)
        XCTAssertNotNil(fakeApplication.lastOpenURL!.absoluteString.rangeOfString("com.venmo.touch.v2"));
    }

    func testAuthorizeAccount_beforeAppSwitch_informsDelegate() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["environment":"sandbox",
            "payWithVenmo" : ["accessToken" : "access-token"],
            "merchantId": "merchant_id" ])
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        let delegate = MockAppSwitchDelegate(willPerform: expectationWithDescription("willPerform called"), didPerform: expectationWithDescription("didPerform called"))
        venmoDriver.appSwitchDelegate = delegate
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoDriver.application = fakeApplication
        venmoDriver.bundle = FakeBundle()

        venmoDriver.authorizeAccountWithCompletion { _ -> Void in
            XCTAssertEqual(delegate.lastAppSwitcher as? BTVenmoDriver, venmoDriver)
        }

        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testAuthorizeAccount_whenUsingTokenizationKeyAndAppSwitchSucceeds_tokenizesVenmoAccount() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["environment":"sandbox",
            "payWithVenmo" : ["accessToken" : "access-token"],
            "merchantId": "merchant_id" ])
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        mockAPIClient = venmoDriver.apiClient as! MockAPIClient
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()

        let expectation = self.expectationWithDescription("Callback")
        venmoDriver.authorizeAccountWithCompletion { (venmoAccount, error) -> Void in
            guard let venmoAccount = venmoAccount else {
                XCTFail("Received an error: \(error)")
                return
            }

            XCTAssertNil(error)
            XCTAssertEqual(venmoAccount.nonce, "fake-nonce")
            XCTAssertEqual(venmoAccount.localizedDescription, "fake-username")
            XCTAssertEqual(venmoAccount.username, "fake-username")
            expectation.fulfill()
        }
        BTVenmoDriver.handleAppSwitchReturnURL(NSURL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)

        self.waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testAuthorizeAccount_whenUsingClientTokenAndAppSwitchSucceeds_tokenizesVenmoAccount() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["environment":"sandbox",
            "payWithVenmo" : ["accessToken" : "access-token"],
            "merchantId": "merchant_id" ])

        // Test setup sets up mockAPIClient with a tokenization key, we want a client token
        mockAPIClient.tokenizationKey = nil
        mockAPIClient.clientToken = try! BTClientToken(clientToken: ValidClientToken)
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        mockAPIClient = venmoDriver.apiClient as! MockAPIClient
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()
        
        let expectation = self.expectationWithDescription("Callback")
        venmoDriver.authorizeAccountWithCompletion { (venmoAccount, error) -> Void in
            guard let venmoAccount = venmoAccount else {
                XCTFail("Received an error: \(error)")
                return
            }
            
            XCTAssertNil(error)
            XCTAssertEqual(venmoAccount.nonce, "fake-nonce")
            XCTAssertEqual(venmoAccount.localizedDescription, "fake-username")
            XCTAssertEqual(venmoAccount.username, "fake-username")
            expectation.fulfill()
        }
        BTVenmoDriver.handleAppSwitchReturnURL(NSURL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        
        self.waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testAuthorizeAccount_whenAppSwitchSucceeds_makesDelegateCallbacks() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["environment":"sandbox",
            "payWithVenmo" : ["accessToken" : "access-token"],
            "merchantId": "merchant_id" ])
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        let delegate = MockAppSwitchDelegate(willPerform: expectationWithDescription("willPerform called"), didPerform: expectationWithDescription("didPerform called"))
        venmoDriver.appSwitchDelegate = delegate
        mockAPIClient = venmoDriver.apiClient as! MockAPIClient
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()

        let expectation = self.expectationWithDescription("Callback")
        venmoDriver.authorizeAccountWithCompletion { _ -> Void in
            XCTAssertEqual(delegate.lastAppSwitcher as? BTVenmoDriver, venmoDriver)
            expectation.fulfill()
        }
        BTVenmoDriver.handleAppSwitchReturnURL(NSURL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)

        self.waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testAuthorizeAccount_whenAppSwitchSucceeds_postsNotifications() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["environment":"sandbox",
            "payWithVenmo" : ["accessToken" : "access-token"],
            "merchantId": "merchant_id" ])
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        let delegate = MockAppSwitchDelegate(willPerform: expectationWithDescription("willPerform called"), didPerform: expectationWithDescription("didPerform called"))
        venmoDriver.appSwitchDelegate = delegate
        mockAPIClient = venmoDriver.apiClient as! MockAPIClient
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()

        let willAppSwitchNotificationExpectation = expectationWithDescription("willAppSwitch notification received")
        observers.append(NSNotificationCenter.defaultCenter().addObserverForName(BTAppSwitchWillSwitchNotification, object: nil, queue: nil) { (notification) -> Void in
            willAppSwitchNotificationExpectation.fulfill()
            })

        let didAppSwitchNotificationExpectation = expectationWithDescription("didAppSwitch notification received")
        observers.append(NSNotificationCenter.defaultCenter().addObserverForName(BTAppSwitchDidSwitchNotification, object: nil, queue: nil) { (notification) -> Void in
            didAppSwitchNotificationExpectation.fulfill()
            })

        venmoDriver.authorizeAccountWithCompletion { _ -> Void in }

        let willProcessNotificationExpectation = expectationWithDescription("willProcess notification received")
        observers.append(NSNotificationCenter.defaultCenter().addObserverForName(BTAppSwitchWillProcessPaymentInfoNotification, object: nil, queue: nil) { (notification) -> Void in
            willProcessNotificationExpectation.fulfill()
            })

        BTVenmoDriver.handleAppSwitchReturnURL(NSURL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)

        self.waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testAuthorizeAccount_whenAppSwitchFails_callsBackWithError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["environment":"sandbox",
            "payWithVenmo" : ["accessToken" : "access-token"],
            "merchantId": "merchant_id" ])
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        mockAPIClient = venmoDriver.apiClient as! MockAPIClient
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()

        let expectation = self.expectationWithDescription("Callback invoked")
        venmoDriver.authorizeAccountWithCompletion { (venmoAccount, error) -> Void in
            guard let error = error else {
                XCTFail("Did not receive expected error")
                return
            }

            XCTAssertNil(venmoAccount)
            XCTAssertEqual(error.domain, "com.braintreepayments.BTVenmoAppSwitchReturnURLErrorDomain")
            expectation.fulfill()
        }
        BTVenmoDriver.handleAppSwitchReturnURL(NSURL(string: "scheme://x-callback-url/vzero/auth/venmo/error")!)

        self.waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testAuthorizeAccount_whenAppSwitchCancelled_callsBackWithNoError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: ["environment":"sandbox",
            "payWithVenmo" : ["accessToken" : "access-token"],
            "merchantId": "merchant_id" ])
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        mockAPIClient = venmoDriver.apiClient as! MockAPIClient
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()

        let expectation = self.expectationWithDescription("Callback invoked")
        venmoDriver.authorizeAccountWithCompletion { (venmoAccount, error) -> Void in
            XCTAssertNil(venmoAccount)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        BTVenmoDriver.handleAppSwitchReturnURL(NSURL(string: "scheme://x-callback-url/vzero/auth/venmo/cancel")!)

        self.waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    // MARK: - Analytics
    
    func testAPIClientMetadata_hasSourceSetToVenmoApp() {
        // API client by default uses source = .Unknown and integration = .Custom
        let apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")!
        let venmoDriver = BTVenmoDriver(APIClient: apiClient)
        
        XCTAssertEqual(venmoDriver.apiClient.metadata.integration, BTClientMetadataIntegrationType.Custom)
        XCTAssertEqual(venmoDriver.apiClient.metadata.source, BTClientMetadataSourceType.VenmoApp)
    }

    // MARK: - Drop-in

    /// Helper
    func client(configurationDictionary: Dictionary<String, String>) -> BTAPIClient {
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")!
        let fakeHttp = BTFakeHTTP()!
        fakeHttp.cannedResponse = BTJSON(value: configurationDictionary)
        fakeHttp.cannedStatusCode = 200
        apiClient.http = fakeHttp
        return apiClient
    }
    
    func clientWithJson(configurationJson: BTJSON) -> BTAPIClient {
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")!
        let fakeHttp = BTFakeHTTP()!
        fakeHttp.cannedResponse = configurationJson
        fakeHttp.cannedStatusCode = 200
        apiClient.http = fakeHttp
        return apiClient
    }

    class BTDropInViewControllerTestDelegate : NSObject, BTDropInViewControllerDelegate {
        var didLoadExpectation: XCTestExpectation

        init(didLoadExpectation: XCTestExpectation) {
            self.didLoadExpectation = didLoadExpectation
        }

        @objc func dropInViewController(viewController: BTDropInViewController, didSucceedWithTokenization paymentMethodNonce: BTPaymentMethodNonce) {}

        @objc func dropInViewControllerDidCancel(viewController: BTDropInViewController) {}

        @objc func dropInViewControllerDidLoad(viewController: BTDropInViewController) {
            didLoadExpectation.fulfill()
        }
    }

    func testFetchConfiguration_whenVenmoIsOff_isVenmoEnabledIsFalse() {
        let apiClient = self.client(["venmo": "off"])

        let expectation = self.expectationWithDescription("Fetch configuration")
        apiClient.fetchOrReturnRemoteConfiguration { (configuration, error) -> Void in
            XCTAssertNotNil(configuration)
            XCTAssertNil(error)
            XCTAssertFalse(configuration!.isVenmoEnabled)
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(5, handler: nil)
    }

    func testDropIn_whenVenmoIsNotEnabled_doesNotDisplayVenmoButton() {
        let apiClient = self.client(["venmo": "off"])

        let dropInViewController = BTDropInViewController(APIClient: apiClient)
        let didLoadExpectation = self.expectationWithDescription("Drop-in did finish loading")

        // Must be assigned here for a strong reference. The delegate property of the BTDropInViewController is a weak reference.
        let testDelegate = BTDropInViewControllerTestDelegate(didLoadExpectation: didLoadExpectation)
        dropInViewController.delegate = testDelegate
        
        let window = UIWindow()
        let viewController = UIViewController()
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        viewController.presentViewController(dropInViewController, animated: false, completion: nil)
        self.waitForExpectationsWithTimeout(5, handler: nil)

        let filteredEnabledPaymentOptions = dropInViewController.dropInContentView.paymentButton.filteredEnabledPaymentOptions()
        XCTAssertFalse(filteredEnabledPaymentOptions.containsObject("Venmo"))
    }

    func testDropIn_whenVenmoIsEnabled_displaysVenmoButton() {
        let json = BTJSON(value: [
            "payWithVenmo" : ["accessToken" : "access-token"],
            "merchantId": "merchant_id" ])
        let apiClient = self.clientWithJson(json)
        BTConfiguration.enableVenmo(true)
        
        let dropInViewController = BTDropInViewController(APIClient: apiClient)
        let didLoadExpectation = self.expectationWithDescription("Drop-in did finish loading")

        // Must be assigned here for a strong reference. The delegate property of the BTDropInViewController is a weak reference.
        let testDelegate = BTDropInViewControllerTestDelegate(didLoadExpectation: didLoadExpectation)
        
        dropInViewController.delegate = testDelegate

        
        let window = UIWindow()
        let viewController = UIViewController()
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        dropInViewController.dropInContentView.paymentButton.application = FakeApplication()
        viewController.presentViewController(dropInViewController, animated: false, completion: nil)
        self.waitForExpectationsWithTimeout(5, handler: nil)

        let filteredEnabledPaymentOptions = dropInViewController.dropInContentView.paymentButton.filteredEnabledPaymentOptions()
        XCTAssertTrue(filteredEnabledPaymentOptions.containsObject("Venmo"))
    }
}

