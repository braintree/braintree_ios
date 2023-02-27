import XCTest
import UIKit
import BraintreeVenmo
@testable import BraintreeCore
@testable import BraintreeTestShared

class BTVenmoClient_Tests: XCTestCase {
    var mockAPIClient : MockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
    var venmoRequest: BTVenmoRequest = BTVenmoRequest(paymentMethodUsage: .multiUse)

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

        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "data": [
                "createVenmoPaymentContext": [
                    "venmoPaymentContext": [
                        "id": "some-resource-id"
                    ]
                ]
            ]
        ])
    }

    func testTokenizeVenmoAccount_whenAPIClientIsNil_callsBackWithError() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        venmoClient.apiClient = nil

        let expectation = self.expectation(description: "Callback invoked with error")
        venmoClient.tokenizeVenmoAccount(with: venmoRequest) { (venmoAccount, error) -> Void in
            XCTAssertNil(venmoAccount)
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTVenmoErrorDomain)
            XCTAssertEqual(error.code, BTVenmoErrorType.integration.rawValue)
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testTokenizeVenmoAccount_whenRemoteConfigurationFetchFails_callsBackWithConfigurationError() {
        mockAPIClient.cannedConfigurationResponseError = NSError(domain: "", code: 0, userInfo: nil)
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"

        let expectation = self.expectation(description: "Tokenize fails with error")
        venmoClient.tokenizeVenmoAccount(with: venmoRequest)  { (venmoAccount, error) -> Void in
            XCTAssertEqual(error! as NSError, self.mockAPIClient.cannedConfigurationResponseError!)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testTokenizeVenmoAccount_whenVenmoConfigurationDisabled_callsBackWithError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [:])
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"

        let expectation = self.expectation(description: "tokenization callback")
        venmoClient.tokenizeVenmoAccount(with: venmoRequest) { (venmoAccount, error) -> Void in
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTVenmoErrorDomain)
            XCTAssertEqual(error.code, BTVenmoErrorType.disabled.rawValue)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testTokenizeVenmoAccount_whenVenmoConfigurationMissing_callsBackWithError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [:])
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"

        let expectation = self.expectation(description: "tokenization callback")
        venmoClient.tokenizeVenmoAccount(with: venmoRequest) { (venmoAccount, error) -> Void in
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTVenmoErrorDomain)
            XCTAssertEqual(error.code, BTVenmoErrorType.disabled.rawValue)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testTokenizeVenmoAccount_whenReturnURLSchemeIsNil_andCallsBackWithError() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = ""
        
        let expectation = self.expectation(description: "authorization callback")
        venmoClient.tokenizeVenmoAccount(with: venmoRequest) { (venmoAccount, error) -> Void in
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTVenmoErrorDomain)
            XCTAssertEqual(error.code, BTVenmoErrorType.appNotAvailable.rawValue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testTokenizeVenmoAccount_whenPaymentMethodUsageSet_createsPaymentContext() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        venmoRequest.displayName = "app-display-name"
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoClient.tokenizeVenmoAccount(with: venmoRequest) { _, _ in }

        XCTAssertEqual(mockAPIClient.lastPOSTAPIClientHTTPType, .graphQLAPI)
        XCTAssertEqual(mockAPIClient.lastPOSTParameters as NSObject?, [
            "query": "mutation CreateVenmoPaymentContext($input: CreateVenmoPaymentContextInput!) { createVenmoPaymentContext(input: $input) { venmoPaymentContext { id } } }",
            "variables": [
                "input" : [
                    "customerClient": "MOBILE_APP",
                    "intent": "CONTINUE",
                    "merchantProfileId": "venmo_merchant_id",
                    "paymentMethodUsage": "MULTI_USE",
                    "displayName": "app-display-name",
                    "collectBillingAddress": false,
                    "collectShippingAddress": false
                ]
            ]
        ] as NSObject)
    }
    
    func testTokenizeVenmoAccount_whenPaymentDataIsSpecified_createsPaymentContext() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        venmoRequest.displayName = "app-display-name"
        venmoRequest.collectBillingAddress = true
        venmoRequest.collectShippingAddress = true
        venmoRequest.subTotalAmount = "8.00"
        venmoRequest.totalAmount = "9.00"
        venmoRequest.discountAmount = "0.99"
        venmoRequest.shippingAmount = "1.01"
        venmoRequest.taxAmount = "1.00"
        var lineItem1 = BTPayPalLineItem(quantity: "1", unitAmount: "12.00", name: "Debit 1", kind: .debit)
        var lineItem2 = BTPayPalLineItem(quantity: "1", unitAmount: "4.00", name: "Credit 1", kind: .credit)
        venmoRequest.lineItems = [lineItem1, lineItem2]
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoClient.tokenizeVenmoAccount(with: venmoRequest) { _, _ in }

        XCTAssertEqual(mockAPIClient.lastPOSTAPIClientHTTPType, .graphQLAPI)
        XCTAssertEqual(mockAPIClient.lastPOSTParameters as NSObject?, [
            "query": "mutation CreateVenmoPaymentContext($input: CreateVenmoPaymentContextInput!) { createVenmoPaymentContext(input: $input) { venmoPaymentContext { id } } }",
            "variables": [
                "input" : [
                    "customerClient": "MOBILE_APP",
                    "intent": "CONTINUE",
                    "merchantProfileId": "venmo_merchant_id",
                    "paymentMethodUsage": "MULTI_USE",
                    "displayName": "app-display-name",
                    "collectBillingAddress": true,
                    "collectShippingAddress": true,
                    "subTotalAmount": "8.00",
                    "totalAmount": "9.00",
                    "discountAmount": "0.99",
                    "shippingAmount": "1.01",
                    "taxAmount": "1.00",
                    "lineItems": [
                        [
                            "name": "Debit 1",
                            "quantity": "1",
                            "unitAmount": "12.00",
                            "type": "DEBIT"
                        ],
                        [
                            "name": "Credit 1",
                            "quantity": "1",
                            "unitAmount": "4.00",
                            "type": "CREDIT"
                        ]
                    ]
                ]
            ]
        ] as NSObject)
    }

    func testTokenizeVenmoAccount_whenDisplayNameNotSet_createsPaymentContextWithoutDisplayName() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoClient.tokenizeVenmoAccount(with: venmoRequest) { _, _ in }

        XCTAssertEqual(mockAPIClient.lastPOSTAPIClientHTTPType, .graphQLAPI)
        XCTAssertEqual(mockAPIClient.lastPOSTParameters as NSObject?, [
            "query": "mutation CreateVenmoPaymentContext($input: CreateVenmoPaymentContextInput!) { createVenmoPaymentContext(input: $input) { venmoPaymentContext { id } } }",
            "variables": [
                "input" : [
                    "customerClient": "MOBILE_APP",
                    "intent": "CONTINUE",
                    "merchantProfileId": "venmo_merchant_id",
                    "paymentMethodUsage": "MULTI_USE"
                ]
            ]
        ] as NSObject)
    }

    func testTokenizeVenmoAccount_opensVenmoURLWithPaymentContextID() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoClient.tokenizeVenmoAccount(with: venmoRequest) { _,_  -> Void in }

        XCTAssertTrue(fakeApplication.openURLWasCalled)

        guard let urlComponents = fakeApplication.lastOpenURL.flatMap({ URLComponents(url: $0, resolvingAgainstBaseURL: false)}),
              let queryItems = urlComponents.queryItems else {
            XCTFail()
            return
        }

        XCTAssertEqual(urlComponents.scheme, "com.venmo.touch.v2")
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "braintree_merchant_id", value: "venmo_merchant_id")))
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "braintree_access_token", value: "venmo-access-token")))
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "braintree_environment", value: "sandbox")))
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "resource_id", value: "some-resource-id")))

    }

    func testTokenizeVenmoAccount_whenCannotParsePaymentContextID_callsBackWithError() {
        mockAPIClient.cannedResponseBody = BTJSON(value: ["random":["lady_gaga":"poker_face"]])

        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        let expectation = self.expectation(description: "Callback invoked")
        venmoClient.tokenizeVenmoAccount(with: venmoRequest) { (venmoAccount, error) -> Void in
            XCTAssertNil(venmoAccount)
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, "com.braintreepayments.BTVenmoErrorDomain")
            XCTAssertEqual(error.code, BTVenmoErrorType.invalidRequestURL.rawValue)
            XCTAssertEqual(error.localizedDescription, "Failed to parse a Venmo paymentContextID while constructing the requestURL. Please contact support.")
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 2, handler: nil)
    }

    func testTokenizeVenmoAccount_whenFetchPaymentContextIDFails_callsBackWithError() {
        mockAPIClient.cannedResponseError = NSError(domain: "Venmo Error", code: 100, userInfo: nil)

        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        let expectation = self.expectation(description: "Callback invoked")
        venmoClient.tokenizeVenmoAccount(with: venmoRequest) { (venmoAccount, error) -> Void in
            XCTAssertNil(venmoAccount)
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, "com.braintreepayments.BTVenmoErrorDomain")
            XCTAssertEqual(error.code, BTVenmoErrorType.invalidRequestURL.rawValue)
            XCTAssertEqual(error.localizedDescription, "Failed to fetch a Venmo paymentContextID while constructing the requestURL.")
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 2, handler: nil)
    }

    func testTokenizeVenmoAccount_whenVenmoIsEnabledInControlPanelAndConfiguredCorrectly_opensVenmoURLWithParams() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoClient.tokenizeVenmoAccount(with: venmoRequest) { _,_  -> Void in }

        XCTAssertTrue(fakeApplication.openURLWasCalled)

        guard let urlComponents = fakeApplication.lastOpenURL.flatMap({ URLComponents(url: $0, resolvingAgainstBaseURL: false)}),
              let queryItems = urlComponents.queryItems else {
            XCTFail()
            return
        }

        XCTAssertEqual(urlComponents.scheme, "com.venmo.touch.v2")
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "braintree_merchant_id", value: "venmo_merchant_id")))
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "braintree_access_token", value: "venmo-access-token")))
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "braintree_environment", value: "sandbox")))
    }

    func testTokenizeVenmoAccount_whenReturnURLContainsPaymentContextID_getsResultFromPaymentContext() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()

        let expectation = self.expectation(description: "Callback")
        venmoClient.tokenizeVenmoAccount(with: venmoRequest) { venmoAccount, error in
            XCTAssertNil(error)
            XCTAssertEqual(venmoAccount?.nonce, "fake-venmo-nonce")
            XCTAssertEqual(venmoAccount?.username, "fake-venmo-username")
            expectation.fulfill()
        }

        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "data": [
                "node": [
                    "paymentMethodId": "fake-venmo-nonce",
                    "userName": "fake-venmo-username"
                ]
            ]
        ])

        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?resource_id=12345")!)

        self.waitForExpectations(timeout: 1)
    }

    func testTokenizeVenmoAccount_whenReturnURLContainsPaymentContextID_andFetchPaymentContextFails_returnsError() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()

        let expectation = self.expectation(description: "Callback")
        venmoClient.tokenizeVenmoAccount(with: venmoRequest) { venmoAccount, error in
            XCTAssertNotNil(error)
            XCTAssertNil(venmoAccount?.nonce)
            XCTAssertNil(venmoAccount?.username)
            expectation.fulfill()
        }

        mockAPIClient.cannedResponseBody = nil
        mockAPIClient.cannedResponseError = NSError(domain: "some-domain", code: 1, userInfo: nil)

        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?resource_id=12345")!)

        self.waitForExpectations(timeout: 1)
    }

    func testTokenizeVenmoAccount_whenUsingTokenizationKeyAndAppSwitchSucceeds_tokenizesVenmoAccount() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()

        let expectation = self.expectation(description: "Callback")
        venmoClient.tokenizeVenmoAccount(with: venmoRequest) { (venmoAccount, error) -> Void in
            guard let venmoAccount = venmoAccount else {
                XCTFail("Received an error: \(String(describing: error))")
                return
            }

            XCTAssertNil(error)
            XCTAssertEqual(venmoAccount.nonce, "fake-nonce")
            XCTAssertEqual(venmoAccount.username, "fake-username")
            expectation.fulfill()
        }
        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)

        self.waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testTokenizeVenmoAccount_whenUsingClientTokenAndAppSwitchSucceeds_tokenizesVenmoAccount() {
        // Test setup sets up mockAPIClient with a tokenization key, we want a client token
        mockAPIClient.tokenizationKey = nil
        mockAPIClient.clientToken = try! BTClientToken(clientToken: TestClientTokenFactory.token(withVersion: 2))
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()
        
        let expectation = self.expectation(description: "Callback")
        venmoClient.tokenizeVenmoAccount(with: venmoRequest) { (venmoAccount, error) -> Void in
            guard let venmoAccount = venmoAccount else {
                XCTFail("Received an error: \(String(describing: error))")
                return
            }
            
            XCTAssertNil(error)
            XCTAssertEqual(venmoAccount.nonce, "fake-nonce")
            XCTAssertEqual(venmoAccount.username, "fake-username")
            expectation.fulfill()
        }
        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        
        self.waitForExpectations(timeout: 2, handler: nil)
    }

    func testTokenizeVenmoAccount_whenAppSwitchFails_callsBackWithError() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()

        let expectation = self.expectation(description: "Callback invoked")
        venmoClient.tokenizeVenmoAccount(with: venmoRequest) { (venmoAccount, error) -> Void in
            XCTAssertNil(venmoAccount)
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, "com.braintreepayments.BTVenmoAppSwitchReturnURLErrorDomain")
            expectation.fulfill()
        }
        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/error")!)

        self.waitForExpectations(timeout: 2, handler: nil)
    }

    func testTokenizeVenmoAccount_vaultTrue_setsShouldVaultProperty() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()

        let expectation = self.expectation(description: "Callback invoked")

        venmoRequest.vault = true

        venmoClient.tokenizeVenmoAccount(with: venmoRequest) { (venmoAccount, error) -> Void in
            XCTAssertTrue(venmoClient.shouldVault)
            expectation.fulfill()
        }

        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        self.waitForExpectations(timeout: 2, handler: nil)
    }

    func testTokenizeVenmoAccount_vaultFalse_setsVaultToFalse() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()
        
        let expectation = self.expectation(description: "Callback invoked")
        
        venmoClient.tokenizeVenmoAccount(with: venmoRequest) { (venmoAccount, error) -> Void in
            XCTAssertFalse(venmoClient.shouldVault)
            expectation.fulfill()
        }
        
        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        self.waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testTokenizeVenmoAccount_vaultTrue_callsBackWithNonce() {
        mockAPIClient.tokenizationKey = nil
        mockAPIClient.clientToken = try! BTClientToken(clientToken: TestClientTokenFactory.validClientToken)

        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()
        
        let expectation = self.expectation(description: "Callback invoked")

        venmoRequest.vault = true

        venmoClient.tokenizeVenmoAccount(with: venmoRequest) { (venmoAccount, error) -> Void in
            XCTAssertNil(error)
            
            XCTAssertEqual(venmoAccount?.username, "venmojoe")
            XCTAssertEqual(venmoAccount?.nonce, "abcd-venmo-nonce")
            XCTAssertTrue(venmoAccount!.isDefault)
            
            expectation.fulfill()
        }

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

        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        self.waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testTokenizeVenmoAccount_vaultTrue_sendsSucessAnalyticsEvent() {
        mockAPIClient.tokenizationKey = nil
        mockAPIClient.clientToken = try! BTClientToken(clientToken: TestClientTokenFactory.validClientToken)

        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"

        let expectation = self.expectation(description: "Callback invoked")

        venmoRequest.vault = true

        venmoClient.tokenizeVenmoAccount(with: venmoRequest) { (venmoAccount, error) -> Void in
            XCTAssertNil(error)

            XCTAssertEqual(venmoAccount?.username, "venmojoe")
            XCTAssertEqual(venmoAccount?.nonce, "abcd-venmo-nonce")
            XCTAssertTrue(venmoAccount!.isDefault)

            expectation.fulfill()
        }

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

        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        self.waitForExpectations(timeout: 2, handler: nil)

        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, "ios.pay-with-venmo.vault.success")
    }

    func testTokenizeVenmoAccount_vaultTrue_sendsFailureAnalyticsEvent() {
        mockAPIClient.tokenizationKey = nil
        mockAPIClient.clientToken = try! BTClientToken(clientToken: TestClientTokenFactory.validClientToken)
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"

        let expectation = self.expectation(description: "Callback invoked")

        venmoRequest.vault = true

        venmoClient.tokenizeVenmoAccount(with: venmoRequest) { (venmoAccount, error) -> Void in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }

        mockAPIClient.cannedResponseError = NSError(domain: "Fake Error", code: 400, userInfo: nil)

        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        self.waitForExpectations(timeout: 2, handler: nil)

        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, "ios.pay-with-venmo.vault.failure")
    }

    func testTokenizeVenmoAccount_whenAppSwitchCanceled_callsBackWithNoError() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"

        let expectation = self.expectation(description: "Callback invoked")
        venmoClient.tokenizeVenmoAccount(with: venmoRequest) { (venmoAccount, error) -> Void in
            XCTAssertNil(venmoAccount)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/cancel")!)

        self.waitForExpectations(timeout: 2, handler: nil)
    }

    func testAuthorizeAccountWithProfileID_withNilProfileID_usesDefaultProfileIDAndAccessTokenFromConfiguration() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoClient.tokenizeVenmoAccount(with: venmoRequest) { (_, _) in }

        XCTAssertTrue(fakeApplication.openURLWasCalled)
        XCTAssertEqual(fakeApplication.lastOpenURL!.scheme, "com.venmo.touch.v2")
        XCTAssertNotNil(fakeApplication.lastOpenURL!.absoluteString.range(of: "venmo_merchant_id"));
        XCTAssertNotNil(fakeApplication.lastOpenURL!.absoluteString.range(of: "venmo-access-token"));
    }

    func testAuthorizeAccountWithProfileID_withProfileID_usesProfileIDToAppSwitch() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoRequest.profileID = "second_venmo_merchant_id"

        venmoClient.tokenizeVenmoAccount(with: venmoRequest) { (_, _) in }

        XCTAssertTrue(fakeApplication.openURLWasCalled)
        XCTAssertEqual(fakeApplication.lastOpenURL!.scheme, "com.venmo.touch.v2")
        XCTAssertNotNil(fakeApplication.lastOpenURL!.absoluteString.range(of: "second_venmo_merchant_id"));
        XCTAssertNotNil(fakeApplication.lastOpenURL!.absoluteString.range(of: "venmo-access-token"));
    }

    // MARK: - Analytics
    
    func testAPIClientMetadata_hasIntegrationSetToCustom() {
        // API client by default uses source = .Unknown and integration = .Custom
        let apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")!
        let venmoClient = BTVenmoClient(apiClient: apiClient)
        
        XCTAssertEqual(venmoClient.apiClient.metadata.integration, BTClientMetadataIntegration.custom)
    }
    
    func testTokenizeVenmoAccount_whenNetworkConnectionLost_sendsAnalytics() {
        mockAPIClient.cannedResponseError = NSError(domain: NSURLErrorDomain, code: -1005, userInfo: [NSLocalizedDescriptionKey: "The network connection was lost."])
        
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()
        venmoClient.returnURLScheme = "scheme"

        let expectation = self.expectation(description: "Callback invoked")
        venmoClient.tokenizeVenmoAccount(with: venmoRequest) { nonce, error in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)
        
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("ios.pay-with-venmo.network-connection.failure"))
    }
    
    // MARK: - BTAppContextSwitchClient

    func testIsiOSAppSwitchAvailable_whenApplicationCanOpenVenmoURL_returnsTrue() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        fakeApplication.cannedCanOpenURL = false
        fakeApplication.canOpenURLWhitelist.append(URL(string: "com.venmo.touch.v2://x-callback-url/path")!)
        venmoClient.application = fakeApplication

        XCTAssertTrue(venmoClient.isiOSAppAvailableForAppSwitch())
    }

    func testIsiOSAppSwitchAvailable_whenApplicationCantOpenVenmoURL_returnsFalse() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        fakeApplication.cannedCanOpenURL = false
        venmoClient.application = fakeApplication

        XCTAssertFalse(venmoClient.isiOSAppAvailableForAppSwitch())
    }

    func testCanHandleReturnURL_withValidHost_andValidPath_returnsTrue() {
        let host = "x-callback-url"
        let path = "/vzero/auth/venmo/"
        XCTAssertTrue(BTVenmoClient.canHandleReturnURL(URL(string: "fake-scheme://\(host)\(path)fake-result")!))
    }

    func testCanHandleReturnURL_withInvalidHost_andValidPath_returnsFalse() {
        let host = "bad-host"
        let path = "/vzero/auth/venmo/"
        XCTAssertFalse(BTVenmoClient.canHandleReturnURL(URL(string: "fake-scheme://\(host)\(path)fake-result")!))
    }

    func testCanHandleReturnURL_withValidHost_andInvalidPath_returnsFalse() {
        let host = "x-callback-url"
        let path = "/bad/path/"
        XCTAssertFalse(BTVenmoClient.canHandleReturnURL(URL(string: "fake-scheme://\(host)\(path)fake-result")!))
    }

    func testCanHandleReturnURL_withNoHost_andNoPath_returnsFalse() {
        XCTAssertFalse(BTVenmoClient.canHandleReturnURL(URL(string: "fake-scheme://")!))
    }

    func testAuthorizeAccountWithTokenizationKey_vaultTrue_willNotAttemptToVault() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)

        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"

        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()

        let expectation = self.expectation(description: "Callback invoked")
        let venmoRequest = BTVenmoRequest(paymentMethodUsage: .multiUse)
        venmoRequest.vault = true

        venmoClient.tokenizeVenmoAccount(with: venmoRequest) { (venmoAccount, error) -> Void in
            XCTAssertNil(error)

            XCTAssertEqual(venmoAccount?.username, "venmotim")
            XCTAssertEqual(venmoAccount?.nonce, "lmnop-venmo-nonce")
            XCTAssertFalse(venmoAccount!.isDefault)

            expectation.fulfill()
        }

        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=lmnop-venmo-nonce&username=venmotim")!)
        self.waitForExpectations(timeout: 2, handler: nil)

        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, "ios.pay-with-venmo.appswitch.handle.success")
    }

    // Note: testing of handleReturnURL is done implicitly while testing authorizeAccountWithCompletion

    // MARK: - openVenmoAppPageInAppStore

    func testGotoVenmoInAppStore_opensVenmoAppStoreURL_andSendsAnalyticsEvent() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoClient.openVenmoAppPageInAppStore()

        XCTAssertTrue(fakeApplication.openURLWasCalled)
        XCTAssertEqual(fakeApplication.lastOpenURL!.absoluteString, "https://itunes.apple.com/us/app/venmo-send-receive-money/id351727428")
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, "ios.pay-with-venmo.app-store.invoked")
    }
}

