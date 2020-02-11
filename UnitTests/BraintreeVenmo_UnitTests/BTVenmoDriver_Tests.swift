import UIKit
import XCTest

class BTVenmoDriver_Tests: XCTestCase {
    var mockAPIClient : MockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
    var observers : [NSObjectProtocol] = []
    var viewController : UIViewController!

    override func setUp() {
        super.setUp()
        viewController = UIApplication.shared.windows[0].rootViewController
        mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "payWithVenmo" : [
                "environment": "sandbox",
                "merchantId": "venmo_merchant_id",
                "accessToken": "venmo-access-token"
            ]
            ])
    }

    override func tearDown() {
        if viewController.presentedViewController != nil {
            viewController.dismiss(animated: false, completion: nil)
        }

        for observer in observers { NotificationCenter.default.removeObserver(observer) }
        super.tearDown()
    }

    func testAuthorizeAccount_whenAPIClientIsNil_callsBackWithError() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        venmoDriver.apiClient = nil

        let expectation = self.expectation(description: "Callback invoked with error")
        venmoDriver.authorizeAccountAndVault(false) { (venmoAccount, error) -> Void in
            XCTAssertNil(venmoAccount)
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTVenmoDriverErrorDomain)
            XCTAssertEqual(error.code, BTVenmoDriverErrorType.integration.rawValue)
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testAuthorizeAccount_whenRemoteConfigurationFetchFails_callsBackWithConfigurationError() {
        mockAPIClient.cannedConfigurationResponseError = NSError(domain: "", code: 0, userInfo: nil)
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"

        let expectation = self.expectation(description: "Tokenize fails with error")
        venmoDriver.authorizeAccountAndVault(false)  { (venmoAccount, error) -> Void in
            XCTAssertEqual(error! as NSError, self.mockAPIClient.cannedConfigurationResponseError!)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testAuthorizeAccount_whenVenmoConfigurationDisabled_callsBackWithError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [:])
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"

        let expectation = self.expectation(description: "tokenization callback")
        venmoDriver.authorizeAccountAndVault(false) { (venmoAccount, error) -> Void in
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTVenmoDriverErrorDomain)
            XCTAssertEqual(error.code, BTVenmoDriverErrorType.disabled.rawValue)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testAuthorizeAccount_whenVenmoConfigurationMissing_callsBackWithError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [:])
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"

        let expectation = self.expectation(description: "tokenization callback")
        venmoDriver.authorizeAccountAndVault(false) { (venmoAccount, error) -> Void in
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTVenmoDriverErrorDomain)
            XCTAssertEqual(error.code, BTVenmoDriverErrorType.disabled.rawValue)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testAuthorization_whenReturnURLSchemeIsNil_logsCriticalMessageAndCallsBackWithError() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppSwitch.sharedInstance().returnURLScheme = ""

        
        var criticalMessageLogged = false
        BTLogger.shared().logBlock = {
            (level: BTLogLevel, message: String?) in
            if (level == BTLogLevel.critical && message == "Venmo requires a return URL scheme to be configured via [BTAppSwitch setReturnURLScheme:]") {
                criticalMessageLogged = true
            }
            BTLogger.shared().logBlock = nil
            return
        }
        
        let expectation = self.expectation(description: "authorization callback")
        venmoDriver.authorizeAccountAndVault(false) { (venmoAccount, error) -> Void in
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTVenmoDriverErrorDomain)
            XCTAssertEqual(error.code, BTVenmoDriverErrorType.appNotAvailable.rawValue)
            expectation.fulfill()
        }
        
        XCTAssertTrue(criticalMessageLogged)
        
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testAuthorization_whenVenmoIsEnabledInControlPanelAndConfiguredCorrectly_opensVenmoURL() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoDriver.application = fakeApplication
        venmoDriver.bundle = FakeBundle()

        venmoDriver.authorizeAccountAndVault(false) { _,_  -> Void in }

        XCTAssertTrue(fakeApplication.openURLWasCalled)
        XCTAssertEqual(fakeApplication.lastOpenURL!.scheme, "com.venmo.touch.v2")
        XCTAssertNotNil(fakeApplication.lastOpenURL!.absoluteString.range(of: "venmo_merchant_id"));
        XCTAssertNotNil(fakeApplication.lastOpenURL!.absoluteString.range(of: "venmo-access-token"));
        XCTAssertNotNil(fakeApplication.lastOpenURL!.absoluteString.range(of: "sandbox"));
    }
    
    func testAuthorizeAccount_beforeAppSwitch_informsDelegate() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        let delegate = MockAppSwitchDelegate(willPerform: expectation(description: "willPerform called"), didPerform: expectation(description: "didPerform called"))
        delegate.appContextWillSwitchExpectation =  self.expectation(description: "Delegate received appContextWillSwitch")
        venmoDriver.appSwitchDelegate = delegate
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoDriver.application = fakeApplication
        venmoDriver.bundle = FakeBundle()

        venmoDriver.authorizeAccountAndVault(false) { _,_  -> Void in
            XCTAssertEqual(delegate.lastAppSwitcher as? BTVenmoDriver, venmoDriver)
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testAuthorizeAccount_whenUsingTokenizationKeyAndAppSwitchSucceeds_tokenizesVenmoAccount() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()

        let expectation = self.expectation(description: "Callback")
        venmoDriver.authorizeAccountAndVault(false) { (venmoAccount, error) -> Void in
            guard let venmoAccount = venmoAccount else {
                XCTFail("Received an error: \(String(describing: error))")
                return
            }

            XCTAssertNil(error)
            XCTAssertEqual(venmoAccount.nonce, "fake-nonce")
            XCTAssertEqual(venmoAccount.localizedDescription, "fake-username")
            XCTAssertEqual(venmoAccount.username, "fake-username")
            expectation.fulfill()
        }
        BTVenmoDriver.handleAppSwitchReturn(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)

        self.waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testAuthorizeAccount_whenUsingClientTokenAndAppSwitchSucceeds_tokenizesVenmoAccount() {
        // Test setup sets up mockAPIClient with a tokenization key, we want a client token
        mockAPIClient.tokenizationKey = nil
        mockAPIClient.clientToken = try! BTClientToken(clientToken: BTTestClientTokenFactory.token(withVersion: 2))
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()
        
        let expectation = self.expectation(description: "Callback")
        venmoDriver.authorizeAccountAndVault(false) { (venmoAccount, error) -> Void in
            guard let venmoAccount = venmoAccount else {
                XCTFail("Received an error: \(String(describing: error))")
                return
            }
            
            XCTAssertNil(error)
            XCTAssertEqual(venmoAccount.nonce, "fake-nonce")
            XCTAssertEqual(venmoAccount.localizedDescription, "fake-username")
            XCTAssertEqual(venmoAccount.username, "fake-username")
            expectation.fulfill()
        }
        BTVenmoDriver.handleAppSwitchReturn(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        
        self.waitForExpectations(timeout: 2, handler: nil)
    }

    func testAuthorizeAccount_whenAppSwitchSucceeds_makesDelegateCallbacks() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        let delegate = MockAppSwitchDelegate(willPerform: self.expectation(description: "willPerform called"), didPerform: self.expectation(description: "didPerform called"))
        delegate.appContextWillSwitchExpectation =  self.expectation(description: "Delegate received appContextWillSwitch")
        venmoDriver.appSwitchDelegate = delegate
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()

        let expectation = self.expectation(description: "Callback")
        venmoDriver.authorizeAccountAndVault(false) { _,_  -> Void in
            XCTAssertEqual(delegate.lastAppSwitcher as? BTVenmoDriver, venmoDriver)
            expectation.fulfill()
        }
        BTVenmoDriver.handleAppSwitchReturn(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)

        self.waitForExpectations(timeout: 2, handler: nil)
    }

    func testAuthorizeAccount_whenAppSwitchSucceeds_postsNotifications() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        let delegate = MockAppSwitchDelegate(willPerform: expectation(description: "willPerform called"), didPerform: expectation(description: "didPerform called"))
        venmoDriver.appSwitchDelegate = delegate
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()

        let willAppSwitchNotificationExpectation = expectation(description: "willAppSwitch notification received")
        observers.append(NotificationCenter.default.addObserver(forName: NSNotification.Name.BTAppSwitchWillSwitch, object: nil, queue: nil) { (notification) -> Void in
            willAppSwitchNotificationExpectation.fulfill()
        })

        let appContextWillSwitchNotificationExpectation = expectation(description: "appContextWillSwitch notification received")
        observers.append(NotificationCenter.default.addObserver(forName: NSNotification.Name.BTAppContextWillSwitch, object: nil, queue: nil) { (notification) -> Void in
            appContextWillSwitchNotificationExpectation.fulfill()
        })

        let didAppSwitchNotificationExpectation = expectation(description: "didAppSwitch notification received")
        observers.append(NotificationCenter.default.addObserver(forName: NSNotification.Name.BTAppSwitchDidSwitch, object: nil, queue: nil) { (notification) -> Void in
            didAppSwitchNotificationExpectation.fulfill()
        })

        venmoDriver.authorizeAccountAndVault(false) { _,_  -> Void in }

        let appContextDidReturnNotificationExpectation = expectation(description: "appContextDidReturn notification received")
        observers.append(NotificationCenter.default.addObserver(forName: NSNotification.Name.BTAppContextDidReturn, object: nil, queue: nil) { (notification) -> Void in
            appContextDidReturnNotificationExpectation.fulfill()
        })

        let willProcessNotificationExpectation = expectation(description: "willProcess notification received")
        observers.append(NotificationCenter.default.addObserver(forName: NSNotification.Name.BTAppSwitchWillProcessPaymentInfo, object: nil, queue: nil) { (notification) -> Void in
            willProcessNotificationExpectation.fulfill()
        })

        BTVenmoDriver.handleAppSwitchReturn(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)

        self.waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testAuthorizeAccount_whenAppSwitchFails_callsBackWithError() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()

        let expectation = self.expectation(description: "Callback invoked")
        venmoDriver.authorizeAccountAndVault(false) { (venmoAccount, error) -> Void in
            XCTAssertNil(venmoAccount)
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, "com.braintreepayments.BTVenmoAppSwitchReturnURLErrorDomain")
            expectation.fulfill()
        }
        BTVenmoDriver.handleAppSwitchReturn(URL(string: "scheme://x-callback-url/vzero/auth/venmo/error")!)

        self.waitForExpectations(timeout: 2, handler: nil)
    }

    func testAuthorizeAccount_vaultTrue_setsShouldVaultProperty() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()

        let expectation = self.expectation(description: "Callback invoked")

        venmoDriver.authorizeAccountAndVault(true) { (venmoAccount, error) -> Void in
            XCTAssertTrue(venmoDriver.shouldVault)
            expectation.fulfill()
        }

        BTVenmoDriver.handleAppSwitchReturn(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        self.waitForExpectations(timeout: 2, handler: nil)
    }

    func testAuthorizeAccount_vaultFalse_setsVaultToFalse() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()
        
        let expectation = self.expectation(description: "Callback invoked")
        
        venmoDriver.authorizeAccountAndVault(false) { (venmoAccount, error) -> Void in
            XCTAssertFalse(venmoDriver.shouldVault)
            expectation.fulfill()
        }
        
        BTVenmoDriver.handleAppSwitchReturn(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        self.waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testAuthorizeAccount_vaultTrue_callsBackWithNonce() {
        mockAPIClient.tokenizationKey = nil
        mockAPIClient.clientToken = try! BTClientToken(clientToken: BTValidTestClientToken)
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "venmoAccounts": [[
                "type": "VenmoAccount",
                "nonce": "abcd-venmo-nonce",
                "description": "VenmoAccount",
                "consumed": false,
                "default": true,
                "details": [
                    "cardType": "Discover",
                    "username": "venmojoe"
                ]]
            ]
            ])
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()
        
        let expectation = self.expectation(description: "Callback invoked")
        
        venmoDriver.authorizeAccountAndVault(true) { (venmoAccount, error) -> Void in
            XCTAssertNil(error)
            
            XCTAssertEqual(venmoAccount?.username, "venmojoe")
            XCTAssertEqual(venmoAccount?.nonce, "abcd-venmo-nonce")
            XCTAssertTrue(venmoAccount!.isDefault)
            
            expectation.fulfill()
        }
        
        BTVenmoDriver.handleAppSwitchReturn(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        self.waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testAuthorizeAccount_vaultTrue_sendsSucessAnalyticsEvent() {
        mockAPIClient.tokenizationKey = nil
        mockAPIClient.clientToken = try! BTClientToken(clientToken: BTValidTestClientToken)
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "venmoAccounts": [[
                "type": "VenmoAccount",
                "nonce": "abcd-venmo-nonce",
                "description": "VenmoAccount",
                "consumed": false,
                "default": true,
                "details": [
                    "cardType": "Discover",
                    "username": "venmojoe"
                ]
                ]]
            ])
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"

        let expectation = self.expectation(description: "Callback invoked")

        venmoDriver.authorizeAccountAndVault(true) { (venmoAccount, error) -> Void in
            XCTAssertNil(error)

            XCTAssertEqual(venmoAccount?.username, "venmojoe")
            XCTAssertEqual(venmoAccount?.nonce, "abcd-venmo-nonce")
            XCTAssertTrue(venmoAccount!.isDefault)

            expectation.fulfill()
        }

        BTVenmoDriver.handleAppSwitchReturn(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        self.waitForExpectations(timeout: 2, handler: nil)

        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, "ios.pay-with-venmo.vault.success")
    }

    func testAuthorizeAccount_vaultTrue_sendsFailureAnalyticsEvent() {
        mockAPIClient.tokenizationKey = nil
        mockAPIClient.clientToken = try! BTClientToken(clientToken: BTValidTestClientToken)
        mockAPIClient.cannedResponseError = NSError(domain: "Fake Error", code: 400, userInfo: nil)
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        
        let expectation = self.expectation(description: "Callback invoked")
        
        venmoDriver.authorizeAccountAndVault(true) { (venmoAccount, error) -> Void in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        
        BTVenmoDriver.handleAppSwitchReturn(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        self.waitForExpectations(timeout: 2, handler: nil)
        
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, "ios.pay-with-venmo.vault.failure")
    }

    func testAuthorizeAccount_whenAppSwitchCancelled_callsBackWithNoError() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"

        let expectation = self.expectation(description: "Callback invoked")
        venmoDriver.authorizeAccountAndVault(false) { (venmoAccount, error) -> Void in
            XCTAssertNil(venmoAccount)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        BTVenmoDriver.handleAppSwitchReturn(URL(string: "scheme://x-callback-url/vzero/auth/venmo/cancel")!)

        self.waitForExpectations(timeout: 2, handler: nil)
    }

    func testAuthorizeAccountWithProfileID_withNilProfileID_usesDefaultProfileIDAndAccessTokenFromConfiguration() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoDriver.application = fakeApplication
        venmoDriver.bundle = FakeBundle()

        venmoDriver.authorizeAccount(profileID: nil, vault: false) { (_, _) in }

        XCTAssertTrue(fakeApplication.openURLWasCalled)
        XCTAssertEqual(fakeApplication.lastOpenURL!.scheme, "com.venmo.touch.v2")
        XCTAssertNotNil(fakeApplication.lastOpenURL!.absoluteString.range(of: "venmo_merchant_id"));
        XCTAssertNotNil(fakeApplication.lastOpenURL!.absoluteString.range(of: "venmo-access-token"));
    }

    func testAuthorizeAccountWithProfileID_withProfileID_usesProfileIDToAppSwitch() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoDriver.application = fakeApplication
        venmoDriver.bundle = FakeBundle()

        venmoDriver.authorizeAccount(profileID: "second_venmo_merchant_id", vault: false) { (_, _) in }

        XCTAssertTrue(fakeApplication.openURLWasCalled)
        XCTAssertEqual(fakeApplication.lastOpenURL!.scheme, "com.venmo.touch.v2")
        XCTAssertNotNil(fakeApplication.lastOpenURL!.absoluteString.range(of: "second_venmo_merchant_id"));
        XCTAssertNotNil(fakeApplication.lastOpenURL!.absoluteString.range(of: "venmo-access-token"));
    }

    // MARK: - Analytics
    
    func testAPIClientMetadata_hasSourceSetToVenmoApp() {
        // API client by default uses source = .Unknown and integration = .Custom
        let apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")!
        let venmoDriver = BTVenmoDriver(apiClient: apiClient)
        
        XCTAssertEqual(venmoDriver.apiClient.metadata.integration, BTClientMetadataIntegrationType.custom)
        XCTAssertEqual(venmoDriver.apiClient.metadata.source, BTClientMetadataSourceType.venmoApp)
    }

    // MARK: - BTAppSwitchHandler

    func testIsiOSAppSwitchAvailable_whenApplicationCanOpenVenmoURL_returnsTrue() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        fakeApplication.cannedCanOpenURL = false
        fakeApplication.canOpenURLWhitelist.append(URL(string: "com.venmo.touch.v2://x-callback-url/path")!)
        venmoDriver.application = fakeApplication

        XCTAssertTrue(venmoDriver.isiOSAppAvailableForAppSwitch())
    }

    func testIsiOSAppSwitchAvailable_whenApplicationCantOpenVenmoURL_returnsFalse() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        fakeApplication.cannedCanOpenURL = false
        venmoDriver.application = fakeApplication

        XCTAssertFalse(venmoDriver.isiOSAppAvailableForAppSwitch())
    }

    func testIsiOSAppSwitchAvailable_whenApplicationCanOpenVenmoURL_andIosLessThan9_returnsFalse() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        fakeApplication.cannedCanOpenURL = false
        fakeApplication.canOpenURLWhitelist.append(URL(string: "com.venmo.touch.v2://x-callback-url/path")!)
        venmoDriver.application = fakeApplication
        let fakeDevice = FakeDevice()
        venmoDriver.device = fakeDevice

        XCTAssertFalse(venmoDriver.isiOSAppAvailableForAppSwitch())
    }

    func testIsiOSAppSwitchAvailable_whenApplicationCantOpenVenmoURL_andIosEqualTo9_3_returnsFalse() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        fakeApplication.cannedCanOpenURL = false
        venmoDriver.application = fakeApplication
        let fakeDevice = FakeDevice()
        fakeDevice.systemVersion = "9.3"
        venmoDriver.device = fakeDevice

        XCTAssertFalse(venmoDriver.isiOSAppAvailableForAppSwitch())
    }

    func testIsiOSAppSwitchAvailable_whenApplicationCanOpenVenmoURL_andIosEqualTo11_1_returnsTrue() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        fakeApplication.cannedCanOpenURL = false
        fakeApplication.canOpenURLWhitelist.append(URL(string: "com.venmo.touch.v2://x-callback-url/path")!)
        venmoDriver.application = fakeApplication
        let fakeDevice = FakeDevice()
        fakeDevice.systemVersion = "11.1"
        venmoDriver.device = fakeDevice

        XCTAssertTrue(venmoDriver.isiOSAppAvailableForAppSwitch())
    }

    let venmoProductionSourceApplication = "net.kortina.labs.Venmo"
    let venmoDebugSourceApplication = "net.kortina.labs.Venmo.debug"
    let fakeWalletSourceApplication = "com.paypal.PPClient.Debug"

    func testCanHandleAppSwitchReturnURL_whenSourceApplicationIsVenmoDebugApp_returnsTrue() {
        XCTAssertTrue(BTVenmoDriver.canHandleAppSwitchReturn(URL(string: "fake://fake")!, sourceApplication: venmoProductionSourceApplication))
    }

    func testCanHandleAppSwitchReturnURL_whenSourceApplicationIsVenmoProductionApp_returnsTrue() {
        XCTAssertTrue(BTVenmoDriver.canHandleAppSwitchReturn(URL(string: "fake://fake")!, sourceApplication: venmoDebugSourceApplication))
    }

    func testCanHandleAppSwitchReturnURL_whenSourceApplicationIsMissing_andPathIsCorrect_returnsTrue() {
        XCTAssertTrue(BTVenmoDriver.canHandleAppSwitchReturn(URL(string: "doesntmatter://x-callback-url/vzero/auth/venmo/stuffffff")!, sourceApplication: nil))
    }

    func testCanHandleAppSwitchReturnURL_whenSourceApplicationIsMissing_andPathIsNotCorrect_returnsFalse() {
        XCTAssertFalse(BTVenmoDriver.canHandleAppSwitchReturn(URL(string: "fake://fake")!, sourceApplication: nil))
    }

    func testCanHandleAppSwitchReturnURL_whenSourceApplicationIsFakeWalletAppAndURLIsValid_returnsTrue() {
        XCTAssertTrue(BTVenmoDriver.canHandleAppSwitchReturn(URL(string: "doesntmatter://x-callback-url/vzero/auth/venmo/stuffffff")!, sourceApplication: fakeWalletSourceApplication))
    }

    func testCanHandleAppSwitchReturnURL_whenSourceApplicationIsNotVenmo_returnsFalse() {
        XCTAssertFalse(BTVenmoDriver.canHandleAppSwitchReturn(URL(string: "fake://fake")!, sourceApplication: "invalid.source.application"))
    }

    func testAuthorizeAccountWithTokenizationKey_vaultTrue_willNotAttemptToVault() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "venmoAccounts": [[
                "type": "VenmoAccount",
                "nonce": "abcd-venmo-nonce",
                "description": "VenmoAccount",
                "consumed": false,
                "default": true,
                "details": [
                    "cardType": "Discover",
                    "username": "venmojoe"
                ]
                ]]
            ])

        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"

        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()

        let expectation = self.expectation(description: "Callback invoked")

        venmoDriver.authorizeAccountAndVault(true) { (venmoAccount, error) -> Void in
            XCTAssertNil(error)

            XCTAssertEqual(venmoAccount?.username, "venmotim")
            XCTAssertEqual(venmoAccount?.nonce, "lmnop-venmo-nonce")
            XCTAssertFalse(venmoAccount!.isDefault)

            expectation.fulfill()
        }

        BTVenmoDriver.handleAppSwitchReturn(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=lmnop-venmo-nonce&username=venmotim")!)
        self.waitForExpectations(timeout: 2, handler: nil)

        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, "ios.pay-with-venmo.appswitch.handle.success")
    }

    // Note: testing of handleAppSwitchReturnURL is done implicitly while testing authorizeAccountWithCompletion

    // MARK: - Drop-in

    /// Helper
    func client(_ configurationDictionary: Dictionary<String, String>) -> BTAPIClient {
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")!
        let fakeHttp = BTFakeHTTP()!
        fakeHttp.cannedResponse = BTJSON(value: configurationDictionary)
        fakeHttp.cannedStatusCode = 200
        apiClient.configurationHTTP = fakeHttp
        return apiClient
    }
    
    func clientWithJson(_ configurationJson: BTJSON) -> BTAPIClient {
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

        @objc func drop(_ viewController: BTDropInViewController, didSucceedWithTokenization paymentMethodNonce: BTPaymentMethodNonce) {}

        @objc func drop(inViewControllerDidCancel viewController: BTDropInViewController) {}

        @objc func drop(inViewControllerDidLoad viewController: BTDropInViewController) {
            didLoadExpectation.fulfill()
        }
    }

    func testGotoVenmoInAppStore_opensVenmoAppStoreURL_andSendsAnalyticsEvent() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppSwitch.sharedInstance().returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoDriver.application = fakeApplication
        venmoDriver.bundle = FakeBundle()

        venmoDriver.openVenmoAppPageInAppStore()

        XCTAssertTrue(fakeApplication.openURLWasCalled)
        XCTAssertEqual(fakeApplication.lastOpenURL!.absoluteString, "https://itunes.apple.com/us/app/venmo-send-receive-money/id351727428")
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, "ios.pay-with-venmo.app-store.invoked")
    }

    // Flaky
    func pendDropIn_whenVenmoIsNotEnabled_doesNotDisplayVenmoButton() {
        let apiClient = self.client([:])

        let dropInViewController = BTDropInViewController(apiClient: apiClient)
        let didLoadExpectation = self.expectation(description: "Drop-in did finish loading")

        // Must be assigned here for a strong reference. The delegate property of the BTDropInViewController is a weak reference.
        let testDelegate = BTDropInViewControllerTestDelegate(didLoadExpectation: didLoadExpectation)
        dropInViewController.delegate = testDelegate

        viewController.present(dropInViewController, animated: false, completion: nil)

        self.waitForExpectations(timeout: 5, handler: nil)

        let enabledPaymentOptions = dropInViewController.dropInContentView.paymentButton.enabledPaymentOptions
        XCTAssertFalse(enabledPaymentOptions.contains("Venmo"))
    }

    // Flaky
    func pendDropIn_whenVenmoIsEnabled_displaysVenmoButton() {
        let json = BTJSON(value: [
            "payWithVenmo" : ["accessToken" : "access-token"],
            "merchantId": "merchant_id" ])
        let apiClient = self.clientWithJson(json)

        let dropInViewController = BTDropInViewController(apiClient: apiClient)
        let didLoadExpectation = self.expectation(description: "Drop-in did finish loading")

        // Must be assigned here for a strong reference. The delegate property of the BTDropInViewController is a weak reference.
        let testDelegate = BTDropInViewControllerTestDelegate(didLoadExpectation: didLoadExpectation)
        
        dropInViewController.delegate = testDelegate

        dropInViewController.dropInContentView.paymentButton.application = FakeApplication()

        viewController.present(dropInViewController, animated: false, completion: nil)

        self.waitForExpectations(timeout: 5, handler: nil)

        let enabledPaymentOptions = dropInViewController.dropInContentView.paymentButton.enabledPaymentOptions
        XCTAssertTrue(enabledPaymentOptions.contains("Venmo"))
    }
}

