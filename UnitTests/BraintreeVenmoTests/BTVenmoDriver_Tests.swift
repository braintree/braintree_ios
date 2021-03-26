import XCTest
import UIKit
import BraintreeTestShared
import BraintreeVenmo
import BraintreeCore.Private

class BTVenmoDriver_Tests: XCTestCase {
    var mockAPIClient : MockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
    var observers : [NSObjectProtocol] = []
    var venmoRequest: BTVenmoRequest = BTVenmoRequest()

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

    func testTokenizeVenmoAccount_whenAPIClientIsNil_callsBackWithError() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        venmoDriver.apiClient = nil

        let expectation = self.expectation(description: "Callback invoked with error")
        venmoDriver.tokenizeVenmoAccount(with: venmoRequest) { (venmoAccount, error) -> Void in
            XCTAssertNil(venmoAccount)
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTVenmoDriverErrorDomain)
            XCTAssertEqual(error.code, BTVenmoDriverErrorType.integration.rawValue)
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testTokenizeVenmoAccount_whenRemoteConfigurationFetchFails_callsBackWithConfigurationError() {
        mockAPIClient.cannedConfigurationResponseError = NSError(domain: "", code: 0, userInfo: nil)
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"

        let expectation = self.expectation(description: "Tokenize fails with error")
        venmoDriver.tokenizeVenmoAccount(with: venmoRequest)  { (venmoAccount, error) -> Void in
            XCTAssertEqual(error! as NSError, self.mockAPIClient.cannedConfigurationResponseError!)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testTokenizeVenmoAccount_whenVenmoConfigurationDisabled_callsBackWithError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [:])
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"

        let expectation = self.expectation(description: "tokenization callback")
        venmoDriver.tokenizeVenmoAccount(with: venmoRequest) { (venmoAccount, error) -> Void in
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTVenmoDriverErrorDomain)
            XCTAssertEqual(error.code, BTVenmoDriverErrorType.disabled.rawValue)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testTokenizeVenmoAccount_whenVenmoConfigurationMissing_callsBackWithError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [:])
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"

        let expectation = self.expectation(description: "tokenization callback")
        venmoDriver.tokenizeVenmoAccount(with: venmoRequest) { (venmoAccount, error) -> Void in
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
        venmoDriver.tokenizeVenmoAccount(with: venmoRequest) { (venmoAccount, error) -> Void in
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

        venmoDriver.tokenizeVenmoAccount(with: venmoRequest) { _,_  -> Void in }

        XCTAssertTrue(fakeApplication.openURLWasCalled)
        XCTAssertEqual(fakeApplication.lastOpenURL!.scheme, "com.venmo.touch.v2")
        XCTAssertNotNil(fakeApplication.lastOpenURL!.absoluteString.range(of: "venmo_merchant_id"));
        XCTAssertNotNil(fakeApplication.lastOpenURL!.absoluteString.range(of: "venmo-access-token"));
        XCTAssertNotNil(fakeApplication.lastOpenURL!.absoluteString.range(of: "sandbox"));
    }

    func testTokenizeVenmoAccount_whenUsingTokenizationKeyAndAppSwitchSucceeds_tokenizesVenmoAccount() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()

        let expectation = self.expectation(description: "Callback")
        venmoDriver.tokenizeVenmoAccount(with: venmoRequest) { (venmoAccount, error) -> Void in
            guard let venmoAccount = venmoAccount else {
                XCTFail("Received an error: \(String(describing: error))")
                return
            }

            XCTAssertNil(error)
            XCTAssertEqual(venmoAccount.nonce, "fake-nonce")
            XCTAssertEqual(venmoAccount.username, "fake-username")
            expectation.fulfill()
        }
        BTVenmoDriver.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)

        self.waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testTokenizeVenmoAccount_whenUsingClientTokenAndAppSwitchSucceeds_tokenizesVenmoAccount() {
        // Test setup sets up mockAPIClient with a tokenization key, we want a client token
        mockAPIClient.tokenizationKey = nil
        mockAPIClient.clientToken = try! BTClientToken(clientToken: TestClientTokenFactory.token(withVersion: 2))
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()
        
        let expectation = self.expectation(description: "Callback")
        venmoDriver.tokenizeVenmoAccount(with: venmoRequest) { (venmoAccount, error) -> Void in
            guard let venmoAccount = venmoAccount else {
                XCTFail("Received an error: \(String(describing: error))")
                return
            }
            
            XCTAssertNil(error)
            XCTAssertEqual(venmoAccount.nonce, "fake-nonce")
            XCTAssertEqual(venmoAccount.username, "fake-username")
            expectation.fulfill()
        }
        BTVenmoDriver.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        
        self.waitForExpectations(timeout: 2, handler: nil)
    }

    func testTokenizeVenmoAccount_whenAppSwitchFails_callsBackWithError() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()

        let expectation = self.expectation(description: "Callback invoked")
        venmoDriver.tokenizeVenmoAccount(with: venmoRequest) { (venmoAccount, error) -> Void in
            XCTAssertNil(venmoAccount)
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, "com.braintreepayments.BTVenmoAppSwitchReturnURLErrorDomain")
            expectation.fulfill()
        }
        BTVenmoDriver.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/error")!)

        self.waitForExpectations(timeout: 2, handler: nil)
    }

    func testTokenizeVenmoAccount_vaultTrue_setsShouldVaultProperty() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()

        let expectation = self.expectation(description: "Callback invoked")

        venmoRequest.vault = true

        venmoDriver.tokenizeVenmoAccount(with: venmoRequest) { (venmoAccount, error) -> Void in
            XCTAssertTrue(venmoDriver.shouldVault)
            expectation.fulfill()
        }

        BTVenmoDriver.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        self.waitForExpectations(timeout: 2, handler: nil)
    }

    func testTokenizeVenmoAccount_vaultFalse_setsVaultToFalse() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()
        
        let expectation = self.expectation(description: "Callback invoked")
        
        venmoDriver.tokenizeVenmoAccount(with: venmoRequest) { (venmoAccount, error) -> Void in
            XCTAssertFalse(venmoDriver.shouldVault)
            expectation.fulfill()
        }
        
        BTVenmoDriver.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        self.waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testTokenizeVenmoAccount_vaultTrue_callsBackWithNonce() {
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

        venmoRequest.vault = true

        venmoDriver.tokenizeVenmoAccount(with: venmoRequest) { (venmoAccount, error) -> Void in
            XCTAssertNil(error)
            
            XCTAssertEqual(venmoAccount?.username, "venmojoe")
            XCTAssertEqual(venmoAccount?.nonce, "abcd-venmo-nonce")
            XCTAssertTrue(venmoAccount!.isDefault)
            
            expectation.fulfill()
        }
        
        BTVenmoDriver.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        self.waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testTokenizeVenmoAccount_vaultTrue_sendsSucessAnalyticsEvent() {
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

        venmoRequest.vault = true

        venmoDriver.tokenizeVenmoAccount(with: venmoRequest) { (venmoAccount, error) -> Void in
            XCTAssertNil(error)

            XCTAssertEqual(venmoAccount?.username, "venmojoe")
            XCTAssertEqual(venmoAccount?.nonce, "abcd-venmo-nonce")
            XCTAssertTrue(venmoAccount!.isDefault)

            expectation.fulfill()
        }

        BTVenmoDriver.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        self.waitForExpectations(timeout: 2, handler: nil)

        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, "ios.pay-with-venmo.vault.success")
    }

    func testTokenizeVenmoAccount_vaultTrue_sendsFailureAnalyticsEvent() {
        mockAPIClient.tokenizationKey = nil
        mockAPIClient.clientToken = try! BTClientToken(clientToken: TestClientTokenFactory.validClientToken)
        mockAPIClient.cannedResponseError = NSError(domain: "Fake Error", code: 400, userInfo: nil)
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"
        
        let expectation = self.expectation(description: "Callback invoked")

        venmoRequest.vault = true

        venmoDriver.tokenizeVenmoAccount(with: venmoRequest) { (venmoAccount, error) -> Void in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        
        BTVenmoDriver.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        self.waitForExpectations(timeout: 2, handler: nil)
        
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, "ios.pay-with-venmo.vault.failure")
    }

    func testTokenizeVenmoAccount_whenAppSwitchCanceled_callsBackWithNoError() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        venmoDriver.application = FakeApplication()
        venmoDriver.bundle = FakeBundle()
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"

        let expectation = self.expectation(description: "Callback invoked")
        venmoDriver.tokenizeVenmoAccount(with: venmoRequest) { (venmoAccount, error) -> Void in
            XCTAssertNil(venmoAccount)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        BTVenmoDriver.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/cancel")!)

        self.waitForExpectations(timeout: 2, handler: nil)
    }

    func testAuthorizeAccountWithProfileID_withNilProfileID_usesDefaultProfileIDAndAccessTokenFromConfiguration() {
        let venmoDriver = BTVenmoDriver(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance().returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoDriver.application = fakeApplication
        venmoDriver.bundle = FakeBundle()

        venmoDriver.tokenizeVenmoAccount(with: venmoRequest) { (_, _) in }

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

        venmoRequest.profileID = "second_venmo_merchant_id"

        venmoDriver.tokenizeVenmoAccount(with: venmoRequest) { (_, _) in }

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

    func testCanHandleReturnURL_withValidHost_andValidPath_returnsTrue() {
        let host = "x-callback-url"
        let path = "/vzero/auth/venmo/"
        XCTAssertTrue(BTVenmoDriver.canHandleReturnURL(URL(string: "fake-scheme://\(host)\(path)fake-result")!))
    }

    func testCanHandleReturnURL_withInvalidHost_andValidPath_returnsFalse() {
        let host = "bad-host"
        let path = "/vzero/auth/venmo/"
        XCTAssertFalse(BTVenmoDriver.canHandleReturnURL(URL(string: "fake-scheme://\(host)\(path)fake-result")!))
    }

    func testCanHandleReturnURL_withValidHost_andInvalidPath_returnsFalse() {
        let host = "x-callback-url"
        let path = "/bad/path/"
        XCTAssertFalse(BTVenmoDriver.canHandleReturnURL(URL(string: "fake-scheme://\(host)\(path)fake-result")!))
    }

    func testCanHandleReturnURL_withNoHost_andNoPath_returnsFalse() {
        XCTAssertFalse(BTVenmoDriver.canHandleReturnURL(URL(string: "fake-scheme://")!))
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
        let venmoRequest = BTVenmoRequest()
        venmoRequest.vault = true

        venmoDriver.tokenizeVenmoAccount(with: venmoRequest) { (venmoAccount, error) -> Void in
            XCTAssertNil(error)

            XCTAssertEqual(venmoAccount?.username, "venmotim")
            XCTAssertEqual(venmoAccount?.nonce, "lmnop-venmo-nonce")
            XCTAssertFalse(venmoAccount!.isDefault)

            expectation.fulfill()
        }

        BTVenmoDriver.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=lmnop-venmo-nonce&username=venmotim")!)
        self.waitForExpectations(timeout: 2, handler: nil)

        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, "ios.pay-with-venmo.appswitch.handle.success")
    }

    // Note: testing of handleReturnURL is done implicitly while testing authorizeAccountWithCompletion

    // MARK: - openVenmoAppPageInAppStore

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

