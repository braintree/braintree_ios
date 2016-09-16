import UIKit
import XCTest

class FakeApplication {
    var lastOpenURL : NSURL? = nil
    var openURLWasCalled : Bool = false
    var cannedOpenURLSuccess : Bool = true
    var cannedCanOpenURL : Bool = true
    var canOpenURLWhitelist : [NSURL] = []

    @objc func openURL(url: NSURL) -> Bool {
        lastOpenURL = url
        openURLWasCalled = true
        return cannedOpenURLSuccess
    }

    @objc func canOpenURL(url: NSURL) -> Bool {
        for whitelistURL in canOpenURLWhitelist {
            if whitelistURL.scheme == url.scheme {
                return true
            }
        }
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
    var viewController : UIViewController!

    override func setUp() {
        super.setUp()
        viewController = UIApplication.sharedApplication().windows[0].rootViewController
        mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
    }

    override func tearDown() {
        if viewController.presentedViewController != nil {
            viewController.dismissViewControllerAnimated(false, completion: nil)
        }

        for observer in observers { NSNotificationCenter.defaultCenter().removeObserver(observer) }
        super.tearDown()
    }
    
    func testAuthorizeAccount_whenAPIClientIsNil_callsBackWithError() {
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        venmoDriver.apiClient = nil
        
        let expectation = expectationWithDescription("Callback invoked with error")
        venmoDriver.authorizeAccountAndVault(false) { (tokenizedCard, error) -> Void in
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
        venmoDriver.authorizeAccountAndVault(false)  { (tokenizedCard, error) -> Void in
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
        venmoDriver.authorizeAccountAndVault(false) { (tokenizedCard, error) -> Void in
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
        venmoDriver.authorizeAccountAndVault(false) { (tokenizedCard, error) -> Void in
            XCTAssertEqual(error!.domain, BTVenmoDriverErrorDomain)
            XCTAssertEqual(error!.code, BTVenmoDriverErrorType.Disabled.rawValue)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testAuthorization_whenReturnURLSchemeIsNil_logsCriticalMessageAndCallsBackWithError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "payWithVenmo" : [
                "environment":"sandbox",
                "accessToken": "access-token",
                "merchantId": "merchant_id" ] ])
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
        venmoDriver.authorizeAccountAndVault(false) { (venmoAccount, error) -> Void in
            XCTAssertEqual(error!.domain, BTVenmoDriverErrorDomain)
            XCTAssertEqual(error!.code, BTVenmoDriverErrorType.AppNotAvailable.rawValue)
            expectation.fulfill()
        }
        
        XCTAssertTrue(criticalMessageLogged)
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testAuthorization_whenVenmoIsEnabledInControlPanelAndConfiguredCorrectly_opensVenmoURL() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "environment": "rockbox",
            "merchantId": "top_level_merchant_id",
            "payWithVenmo" : [
                "environment":"venmobox",
                "accessToken": "access-token",
                "merchantId": "venmo_merchant_id" ]
            ])
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoDriver.application = fakeApplication
        venmoDriver.bundle = FakeBundle()

        venmoDriver.authorizeAccountAndVault(false) { _ -> Void in }

        XCTAssertTrue(fakeApplication.openURLWasCalled)
        XCTAssertEqual(fakeApplication.lastOpenURL!.scheme, "com.venmo.touch.v2")
        XCTAssertNotNil(fakeApplication.lastOpenURL!.absoluteString!.rangeOfString("venmo_merchant_id"));
        XCTAssertNotNil(fakeApplication.lastOpenURL!.absoluteString!.rangeOfString("venmobox"));
        XCTAssertNotNil(fakeApplication.lastOpenURL!.absoluteString!.rangeOfString("access-token"));
    }
    
    func testAuthorizeAccount_beforeAppSwitch_informsDelegate() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "payWithVenmo" : [
                "environment":"sandbox",
                "accessToken": "access-token",
                "merchantId": "merchant_id" ] ])
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        let delegate = MockAppSwitchDelegate(willPerform: expectationWithDescription("willPerform called"), didPerform: expectationWithDescription("didPerform called"))
        venmoDriver.appSwitchDelegate = delegate
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoDriver.application = fakeApplication
        venmoDriver.bundle = FakeBundle()

        venmoDriver.authorizeAccountAndVault(false) { _ -> Void in
            XCTAssertEqual(delegate.lastAppSwitcher as? BTVenmoDriver, venmoDriver)
        }

        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testAuthorizeAccount_whenUsingTokenizationKeyAndAppSwitchSucceeds_tokenizesVenmoAccount() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "payWithVenmo" : [
                "environment":"sandbox",
                "accessToken": "access-token",
                "merchantId": "merchant_id" ] ])
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        mockAPIClient = venmoDriver.apiClient as! MockAPIClient
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()

        let expectation = self.expectationWithDescription("Callback")
        venmoDriver.authorizeAccountAndVault(false) { (venmoAccount, error) -> Void in
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
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "payWithVenmo" : [
                "environment":"sandbox",
                "accessToken": "access-token",
                "merchantId": "merchant_id" ] ])
        // Test setup sets up mockAPIClient with a tokenization key, we want a client token
        mockAPIClient.tokenizationKey = nil
        mockAPIClient.clientToken = try! BTClientToken(clientToken: BTTestClientTokenFactory.tokenWithVersion(2))
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        mockAPIClient = venmoDriver.apiClient as! MockAPIClient
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()
        
        let expectation = self.expectationWithDescription("Callback")
        venmoDriver.authorizeAccountAndVault(false) { (venmoAccount, error) -> Void in
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
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "payWithVenmo" : [
                "environment":"sandbox",
                "accessToken": "access-token",
                "merchantId": "merchant_id" ] ])
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        let delegate = MockAppSwitchDelegate(willPerform: expectationWithDescription("willPerform called"), didPerform: expectationWithDescription("didPerform called"))
        venmoDriver.appSwitchDelegate = delegate
        mockAPIClient = venmoDriver.apiClient as! MockAPIClient
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()

        let expectation = self.expectationWithDescription("Callback")
        venmoDriver.authorizeAccountAndVault(false) { _ -> Void in
            XCTAssertEqual(delegate.lastAppSwitcher as? BTVenmoDriver, venmoDriver)
            expectation.fulfill()
        }
        BTVenmoDriver.handleAppSwitchReturnURL(NSURL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)

        self.waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testAuthorizeAccount_whenAppSwitchSucceeds_postsNotifications() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "payWithVenmo" : [
                "environment":"sandbox",
                "accessToken": "access-token",
                "merchantId": "merchant_id" ] ])
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

        venmoDriver.authorizeAccountAndVault(false) { _ -> Void in }

        let willProcessNotificationExpectation = expectationWithDescription("willProcess notification received")
        observers.append(NSNotificationCenter.defaultCenter().addObserverForName(BTAppSwitchWillProcessPaymentInfoNotification, object: nil, queue: nil) { (notification) -> Void in
            willProcessNotificationExpectation.fulfill()
            })

        BTVenmoDriver.handleAppSwitchReturnURL(NSURL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)

        self.waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testAuthorizeAccount_whenAppSwitchFails_callsBackWithError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "payWithVenmo" : [
                "environment":"sandbox",
                "accessToken": "access-token",
                "merchantId": "merchant_id"
            ]
            ])
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        mockAPIClient = venmoDriver.apiClient as! MockAPIClient
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()

        let expectation = self.expectationWithDescription("Callback invoked")
        venmoDriver.authorizeAccountAndVault(false) { (venmoAccount, error) -> Void in
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
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "payWithVenmo" : [
                "environment":"sandbox",
                "accessToken": "access-token",
                "merchantId": "merchant_id" ] ])
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        mockAPIClient = venmoDriver.apiClient as! MockAPIClient
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()

        let expectation = self.expectationWithDescription("Callback invoked")
        venmoDriver.authorizeAccountAndVault(false) { (venmoAccount, error) -> Void in
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

    // MARK: - BTAppSwitchHandler

    func testIsiOSAppSwitchAvailable_whenApplicationCanOpenVenmoURL_returnsTrue() {
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        mockAPIClient = venmoDriver.apiClient as! MockAPIClient
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        fakeApplication.cannedCanOpenURL = false
        fakeApplication.canOpenURLWhitelist.append(NSURL(string: "com.venmo.touch.v2://x-callback-url/path")!)
        venmoDriver.application = fakeApplication

        XCTAssertTrue(venmoDriver.isiOSAppAvailableForAppSwitch())
    }

    func testIsiOSAppSwitchAvailable_whenApplicationCantOpenVenmoURL_returnsFalse() {
        let venmoDriver = BTVenmoDriver(APIClient: mockAPIClient)
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        fakeApplication.cannedCanOpenURL = false
        venmoDriver.application = fakeApplication

        XCTAssertFalse(venmoDriver.isiOSAppAvailableForAppSwitch())
    }

    let venmoProductionSourceApplication = "net.kortina.labs.Venmo"
    let venmoDebugSourceApplication = "net.kortina.labs.Venmo.debug"
    let fakeWalletSourceApplication = "com.paypal.PPClient.Debug"

    func testCanHandleAppSwitchReturnURL_whenSourceApplicationIsVenmoDebugApp_returnsTrue() {
        XCTAssertTrue(BTVenmoDriver.canHandleAppSwitchReturnURL(NSURL(string: "")!, sourceApplication: venmoProductionSourceApplication))
    }

    func testCanHandleAppSwitchReturnURL_whenSourceApplicationIsVenmoProductionApp_returnsTrue() {
        XCTAssertTrue(BTVenmoDriver.canHandleAppSwitchReturnURL(NSURL(string: "")!, sourceApplication: venmoDebugSourceApplication))
    }

    func testCanHandleAppSwitchReturnURL_whenSourceApplicationIsFakeWalletAppAndURLIsValid_returnsTrue() {
        XCTAssertTrue(BTVenmoDriver.canHandleAppSwitchReturnURL(NSURL(string: "doesntmatter://x-callback-url/vzero/auth/venmo/stuffffff")!, sourceApplication: fakeWalletSourceApplication))
    }

    func testCanHandleAppSwitchReturnURL_whenSourceApplicationIsNotVenmo_returnsFalse() {
        XCTAssertFalse(BTVenmoDriver.canHandleAppSwitchReturnURL(NSURL(string: "")!, sourceApplication: "invalid.source.application"))
    }

    // Note: testing of handleAppSwitchReturnURL is done implicitly while testing authorizeAccountWithCompletion

    // MARK: - Drop-in

    /// Helper
    func client(configurationDictionary: Dictionary<String, String>) -> BTAPIClient {
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")!
        let fakeHttp = BTFakeHTTP()!
        fakeHttp.cannedResponse = BTJSON(value: configurationDictionary)
        fakeHttp.cannedStatusCode = 200
        apiClient.configurationHTTP = fakeHttp
        return apiClient
    }
    
    func clientWithJson(configurationJson: BTJSON) -> BTAPIClient {
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")!
        let fakeHttp = BTFakeHTTP()!
        fakeHttp.cannedResponse = configurationJson
        fakeHttp.cannedStatusCode = 200
        apiClient.configurationHTTP = fakeHttp
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

    // Flaky
    func pendDropIn_whenVenmoIsNotEnabled_doesNotDisplayVenmoButton() {
        let apiClient = self.client(["venmo": "off"])

        let dropInViewController = BTDropInViewController(APIClient: apiClient)
        let didLoadExpectation = self.expectationWithDescription("Drop-in did finish loading")

        // Must be assigned here for a strong reference. The delegate property of the BTDropInViewController is a weak reference.
        let testDelegate = BTDropInViewControllerTestDelegate(didLoadExpectation: didLoadExpectation)
        dropInViewController.delegate = testDelegate

        viewController.presentViewController(dropInViewController, animated: false, completion: nil)

        self.waitForExpectationsWithTimeout(5, handler: nil)

        let enabledPaymentOptions = dropInViewController.dropInContentView.paymentButton.enabledPaymentOptions
        XCTAssertFalse(enabledPaymentOptions.containsObject("Venmo"))
    }

    // Flaky
    func pendDropIn_whenVenmoIsEnabled_displaysVenmoButton() {
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

        dropInViewController.dropInContentView.paymentButton.application = FakeApplication()

        viewController.presentViewController(dropInViewController, animated: false, completion: nil)

        self.waitForExpectationsWithTimeout(5, handler: nil)

        let enabledPaymentOptions = dropInViewController.dropInContentView.paymentButton.enabledPaymentOptions
        XCTAssertTrue(enabledPaymentOptions.containsObject("Venmo"))
    }
}

