import XCTest
import UIKit
import BraintreeTestShared
import BraintreeVenmo
import BraintreeCore.Private

class BTVenmoDriver_Tests: XCTestCase {
    var mockAPIClient : MockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
    var observers : [NSObjectProtocol] = []

    override func setUp() {
        super.setUp()
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
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"

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
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"

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
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"

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
        BTAppContextSwitcher.sharedInstance().returnURLScheme = ""

        
        var criticalMessageLogged = false
        BTLogger.shared().logBlock = {
            (level: BTLogLevel, message: String?) in
            if (level == BTLogLevel.critical && message == "Venmo requires a return URL scheme to be configured via [BTAppContextSwitcher setReturnURLScheme:]") {
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
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"
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
        let delegate = MockAppContextSwitchDelegate()
        delegate.appContextWillSwitchExpectation =  self.expectation(description: "Delegate received appContextSwitchDriverWillStartSwitch")
        delegate.appContextDidSwitchExpectation = self.expectation(description: "Delegate received appContextSwitchDriverDidCompleteSwitch")
        venmoDriver.appContextSwitchDelegate = delegate
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoDriver.application = fakeApplication
        venmoDriver.bundle = FakeBundle()

        venmoDriver.authorizeAccountAndVault(false) { _,_  -> Void in
            XCTAssertEqual(delegate.driver as? BTVenmoDriver, venmoDriver)
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testAuthorizeAccount_whenUsingTokenizationKeyAndAppSwitchSucceeds_tokenizesVenmoAccount() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"
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
            XCTAssertEqual(venmoAccount.username, "fake-username")
            expectation.fulfill()
        }
        BTVenmoDriver.handleAppSwitchReturn(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)

        self.waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testAuthorizeAccount_whenUsingClientTokenAndAppSwitchSucceeds_tokenizesVenmoAccount() {
        // Test setup sets up mockAPIClient with a tokenization key, we want a client token
        mockAPIClient.tokenizationKey = nil
        mockAPIClient.clientToken = try! BTClientToken(clientToken: TestClientTokenFactory.token(withVersion: 2))
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"
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
            XCTAssertEqual(venmoAccount.username, "fake-username")
            expectation.fulfill()
        }
        BTVenmoDriver.handleAppSwitchReturn(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        
        self.waitForExpectations(timeout: 2, handler: nil)
    }

    func testAuthorizeAccount_whenAppSwitchSucceeds_makesDelegateCallbacks() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        let delegate = MockAppContextSwitchDelegate()
        delegate.appContextWillSwitchExpectation =  self.expectation(description: "Delegate received appContextSwitchDriverWillStartSwitch")
        delegate.appContextDidSwitchExpectation = self.expectation(description: "Delegate received appContextSwitchDriverDidCompleteSwitch")
        venmoDriver.appContextSwitchDelegate = delegate
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()

        let expectation = self.expectation(description: "Callback")
        venmoDriver.authorizeAccountAndVault(false) { _,_  -> Void in
            XCTAssertEqual(delegate.driver as? BTVenmoDriver, venmoDriver)
            expectation.fulfill()
        }
        BTVenmoDriver.handleAppSwitchReturn(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)

        self.waitForExpectations(timeout: 2, handler: nil)
    }

    func testAuthorizeAccount_whenAppSwitchFails_callsBackWithError() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"
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
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"
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
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"
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
        mockAPIClient.clientToken = try! BTClientToken(clientToken: TestClientTokenFactory.validClientToken)
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
        
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"
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
        mockAPIClient.clientToken = try! BTClientToken(clientToken: TestClientTokenFactory.validClientToken)
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
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"

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
        mockAPIClient.clientToken = try! BTClientToken(clientToken: TestClientTokenFactory.validClientToken)
        mockAPIClient.cannedResponseError = NSError(domain: "Fake Error", code: 400, userInfo: nil)
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"
        
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
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"

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
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"
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
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"
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

    // MARK: - BTAppContextSwitchDriver

    func testIsiOSAppSwitchAvailable_whenApplicationCanOpenVenmoURL_returnsTrue() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        fakeApplication.cannedCanOpenURL = false
        fakeApplication.canOpenURLWhitelist.append(URL(string: "com.venmo.touch.v2://x-callback-url/path")!)
        venmoDriver.application = fakeApplication

        XCTAssertTrue(venmoDriver.isiOSAppAvailableForAppSwitch())
    }

    func testIsiOSAppSwitchAvailable_whenApplicationCantOpenVenmoURL_returnsFalse() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        fakeApplication.cannedCanOpenURL = false
        venmoDriver.application = fakeApplication

        XCTAssertFalse(venmoDriver.isiOSAppAvailableForAppSwitch())
    }

    func testIsiOSAppSwitchAvailable_whenApplicationCanOpenVenmoURL_andIosLessThan9_returnsFalse() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"
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
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"
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
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        fakeApplication.cannedCanOpenURL = false
        fakeApplication.canOpenURLWhitelist.append(URL(string: "com.venmo.touch.v2://x-callback-url/path")!)
        venmoDriver.application = fakeApplication
        let fakeDevice = FakeDevice()
        fakeDevice.systemVersion = "11.1"
        venmoDriver.device = fakeDevice

        XCTAssertTrue(venmoDriver.isiOSAppAvailableForAppSwitch())
    }

    func testCanHandleAppSwitchReturnURL_withValidHost_andValidPath_returnsTrue() {
        let host = "x-callback-url"
        let path = "/vzero/auth/venmo/"
        XCTAssertTrue(BTVenmoDriver.canHandleAppSwitchReturn(URL(string: "fake-scheme://\(host)\(path)fake-result")!))
    }

    func testCanHandleAppSwitchReturnURL_withInvalidHost_andValidPath_returnsFalse() {
        let host = "bad-host"
        let path = "/vzero/auth/venmo/"
        XCTAssertFalse(BTVenmoDriver.canHandleAppSwitchReturn(URL(string: "fake-scheme://\(host)\(path)fake-result")!))
    }

    func testCanHandleAppSwitchReturnURL_withValidHost_andInvalidPath_returnsFalse() {
        let host = "x-callback-url"
        let path = "/bad/path/"
        XCTAssertFalse(BTVenmoDriver.canHandleAppSwitchReturn(URL(string: "fake-scheme://\(host)\(path)fake-result")!))
    }

    func testCanHandleAppSwitchReturnURL_withNoHost_andNoPath_returnsFalse() {
        XCTAssertFalse(BTVenmoDriver.canHandleAppSwitchReturn(URL(string: "fake-scheme://")!))
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

        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"

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
        let fakeHttp = FakeHTTP.fakeHTTP()
        fakeHttp.cannedResponse = BTJSON(value: configurationDictionary)
        fakeHttp.cannedStatusCode = 200
        apiClient.configurationHTTP = fakeHttp
        return apiClient
    }
    
    func clientWithJson(_ configurationJson: BTJSON) -> BTAPIClient {
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")!
        let fakeHttp = FakeHTTP.fakeHTTP()
        fakeHttp.cannedResponse = configurationJson
        fakeHttp.cannedStatusCode = 200
        apiClient.configurationHTTP = fakeHttp
        return apiClient
    }

    func testGotoVenmoInAppStore_opensVenmoAppStoreURL_andSendsAnalyticsEvent() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoDriver.application = fakeApplication
        venmoDriver.bundle = FakeBundle()

        venmoDriver.openVenmoAppPageInAppStore()

        XCTAssertTrue(fakeApplication.openURLWasCalled)
        XCTAssertEqual(fakeApplication.lastOpenURL!.absoluteString, "https://itunes.apple.com/us/app/venmo-send-receive-money/id351727428")
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, "ios.pay-with-venmo.app-store.invoked")
    }
}

