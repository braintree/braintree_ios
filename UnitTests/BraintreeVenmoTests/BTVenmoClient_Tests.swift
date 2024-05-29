import XCTest
import UIKit
@testable import BraintreeVenmo
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

    func testTokenize_whenRemoteConfigurationFetchFails_callsBackWithConfigurationError() {
        mockAPIClient.cannedConfigurationResponseError = NSError(domain: "", code: 0, userInfo: nil)
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"

        let expectation = expectation(description: "Tokenize fails with error")
        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
            XCTAssertEqual(error! as NSError, self.mockAPIClient.cannedConfigurationResponseError!)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testTokenizeVenmoAccount_whenVenmoConfigurationDisabled_callsBackWithError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [:] as [String: Any?])
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"

        let expectation = expectation(description: "tokenization callback")
        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTVenmoError.errorDomain)
            XCTAssertEqual(error.code, BTVenmoError.disabled.errorCode)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)
    }

    func testTokenizeVenmoAccount_whenVenmoConfigurationMissing_callsBackWithError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [:] as [String: Any?])
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"

        let expectation = expectation(description: "tokenization callback")
        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTVenmoError.errorDomain)
            XCTAssertEqual(error.code, BTVenmoError.disabled.errorCode)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)
    }

    func testTokenizeVenmoAccount_whenReturnURLSchemeIsNil_andCallsBackWithError() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = ""
        
        let expectation = expectation(description: "authorization callback")
        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTVenmoError.errorDomain)
            XCTAssertEqual(error.code, BTVenmoError.appNotAvailable.errorCode)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testTokenizeVenmoAccount_whenPaymentMethodUsageSet_createsPaymentContext() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        venmoRequest.displayName = "app-display-name"
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoClient.tokenize(venmoRequest) { _, _ in }

        XCTAssertEqual(mockAPIClient.lastPOSTAPIClientHTTPType, .graphQLAPI)
        let params = mockAPIClient.lastPOSTParameters as? NSDictionary
        if let inputDict = params?["variables"] as? NSDictionary,
           let input = inputDict["input"] as? [String:Any] {
            XCTAssertEqual("MOBILE_APP", input["customerClient"] as? String)
            XCTAssertEqual("venmo_merchant_id",input["merchantProfileId"] as? String)
            XCTAssertEqual("MULTI_USE", input["paymentMethodUsage"] as? String)
            XCTAssertEqual("CONTINUE",input["intent"] as? String)
            XCTAssertEqual("app-display-name",input["displayName"] as? String)
        }
    }

    func testTokenizeVenmoAccount_whenDisplayNameNotSet_createsPaymentContextWithoutDisplayName() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoClient.tokenize(venmoRequest) { _, _ in }

        XCTAssertEqual(mockAPIClient.lastPOSTAPIClientHTTPType, .graphQLAPI)
        let params = mockAPIClient.lastPOSTParameters as? NSDictionary
        if let inputDict = params?["variables"] as? NSDictionary,
           let input = inputDict["input"] as? [String: Any] {
            XCTAssertEqual("MOBILE_APP", input["customerClient"] as? String)
            XCTAssertEqual("venmo_merchant_id",input["merchantProfileId"] as? String)
            XCTAssertEqual("MULTI_USE", input["paymentMethodUsage"] as? String)
            XCTAssertEqual("CONTINUE",input["intent"] as? String)
        }
    }
    
    func testTokenizeVenmoAccount_whenEnrichedCustomerDataDisabled_doesNotAllowCollectingAddresses() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "payWithVenmo" : [
                "environment": "sandbox",
                "merchantId": "venmo_merchant_id",
                "accessToken": "venmo-access-token",
                "enrichedCustomerDataEnabled": false
            ]
        ])

        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        venmoRequest.collectCustomerBillingAddress = true
        venmoRequest.collectCustomerShippingAddress = true
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()
        let expectation = expectation(description: "Tokenize fails with error")

        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.code, BTVenmoError.enrichedCustomerDataDisabled.errorCode)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testTokenizeVenmoAccount_whenCollectAddressFlagsSet_createsPaymentContextWithTheRightFlags() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "payWithVenmo" : [
                "environment": "sandbox",
                "merchantId": "venmo_merchant_id",
                "accessToken": "venmo-access-token",
                "enrichedCustomerDataEnabled": true
            ]
        ])
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        venmoRequest.collectCustomerBillingAddress = true
        venmoRequest.collectCustomerShippingAddress = true
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoClient.tokenize(venmoRequest) { _, _ in }
        
        XCTAssertEqual(mockAPIClient.lastPOSTAPIClientHTTPType, .graphQLAPI)
        
        let params = mockAPIClient.lastPOSTParameters as? NSDictionary
        if let inputDict = params?["variables"] as? NSDictionary,
           let input = inputDict["input"] as? [String: Any] {
            if let paysheetDetails = input["paysheetDetails"] as? String {
                if let jsonData = paysheetDetails.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                    XCTAssertEqual("true",json["collectCustomerShippingAddress"] as? String)
                    XCTAssertEqual("true",json["collectCustomerBillingAddress"] as? String)
                }
            }
        }
    }
    
    func testTokenizeVenmoAccount_withAmountsAndLineItemsSet_createsPaymentContext() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        venmoRequest.subTotalAmount = "9"
        venmoRequest.totalAmount = "9"
        venmoRequest.lineItems = [BTVenmoLineItem(quantity: 1, unitAmount: "9", name: "name", kind: .debit)]
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoClient.tokenize(venmoRequest) { _, _ in }
        
        XCTAssertEqual(mockAPIClient.lastPOSTAPIClientHTTPType, .graphQLAPI)
        
        let params = mockAPIClient.lastPOSTParameters as? NSDictionary
        if let inputDict = params?["variables"] as? NSDictionary,
        let input = inputDict["input"] as? [String: Any] {
            XCTAssertEqual("MOBILE_APP", input["customerClient"] as? String)
            XCTAssertEqual("venmo_merchant_id",input["merchantProfileId"] as? String)
            
            if let paysheetDetails = input["paysheetDetails"] as? String {
                if let jsonData = paysheetDetails.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                    XCTAssertEqual("false",json["collectCustomerShippingAddress"] as? String)
                    XCTAssertEqual("false",json["collectCustomerBillingAddress"] as? String)
                    
                    if let transactionDetailsString = json["transactionDetails"] as? String {
                        if let jsonData = transactionDetailsString.data(using: .utf8),
                           let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                            XCTAssertEqual(json["totalAmount"] as? String, "9")
                            XCTAssertEqual(json["subTotalAmount"] as? String, "9")
                            if let lineItems = json["lineItems"] as? String {
                                XCTAssertTrue(lineItems.contains("\"quantity\":1"))
                                XCTAssertTrue(lineItems.contains("\"name\":\"name"))
                                XCTAssertTrue(lineItems.contains("\"unit_amount\":\"9\""))
                                XCTAssertTrue(lineItems.contains("\"kind\":\"debit\""))
                                XCTAssertTrue(lineItems.contains("\"unit_tax_amount\":\"0\""))
                            }
                        }
                    }
                }
            }
        }
    }
    
    func testTokenize_withoutLineItems_createsPaymentContextWithoutTransactionDetails() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoClient.tokenize(venmoRequest) { _, _ in }
        
        XCTAssertEqual(mockAPIClient.lastPOSTAPIClientHTTPType, .graphQLAPI)
        
        let params = mockAPIClient.lastPOSTParameters as! [String: Any]
        let queryParams = params["query"] as! String
        XCTAssertTrue(queryParams.contains("mutation CreateVenmoPaymentContext"))
        
        let inputParams = (params["variables"] as! [String: [String: Any]])["input"]
        let paysheetDetails = inputParams?["paysheetDetails"] as! [String: Any]
        XCTAssertNil(paysheetDetails["transactionDetails"])
    }

    func testTokenizeVenmoAccount_opensVenmoURLWithPaymentContextID() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoClient.tokenize(venmoRequest) { _, _ in }

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

        let expectation = expectation(description: "Callback invoked")
        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
            XCTAssertNil(venmoAccount)
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, "com.braintreepayments.BTVenmoErrorDomain")
            XCTAssertEqual(error.code, BTVenmoError.invalidRedirectURL("").errorCode)
            XCTAssertEqual(error.localizedDescription, "Failed to parse a Venmo paymentContextID while constructing the requestURL. Please contact support.")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testTokenizeVenmoAccount_whenFetchPaymentContextIDFails_callsBackWithError() {
        mockAPIClient.cannedResponseError = NSError(domain: "Venmo Error", code: 100, userInfo: nil)

        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        let expectation = expectation(description: "Callback invoked")
        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
            XCTAssertNil(venmoAccount)
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, "com.braintreepayments.BTVenmoErrorDomain")
            XCTAssertEqual(error.code, BTVenmoError.invalidRedirectURL("").errorCode)
            XCTAssertEqual(error.localizedDescription, "Failed to fetch a Venmo paymentContextID while constructing the requestURL.")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testTokenizeVenmoAccount_whenVenmoIsEnabledInControlPanelAndConfiguredCorrectly_opensVenmoURLWithParams() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoClient.tokenize(venmoRequest) { _,_  -> Void in }

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

        let expectation = expectation(description: "Callback")
        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
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

        waitForExpectations(timeout: 1)
    }

    func testTokenizeVenmoAccount_whenReturnURLContainsPaymentContextID_andFetchPaymentContextFails_returnsError() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()

        let expectation = expectation(description: "Callback")
        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
            XCTAssertNotNil(error)
            XCTAssertNil(venmoAccount?.nonce)
            XCTAssertNil(venmoAccount?.username)
            expectation.fulfill()
        }

        mockAPIClient.cannedResponseBody = nil
        mockAPIClient.cannedResponseError = NSError(domain: "some-domain", code: 1, userInfo: nil)

        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?resource_id=12345")!)

        waitForExpectations(timeout: 1)
    }

    func testTokenizeVenmoAccount_whenUsingTokenizationKeyAndAppSwitchSucceeds_tokenizesVenmoAccount() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()

        let expectation = expectation(description: "Callback")
        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
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

        waitForExpectations(timeout: 2)
    }
    
    func testTokenizeVenmoAccount_whenUsingClientTokenAndAppSwitchSucceeds_tokenizesVenmoAccount() {
        // Test setup sets up mockAPIClient with a tokenization key, we want a client token
        mockAPIClient.authorization = try! BTClientToken(clientToken: TestClientTokenFactory.token(withVersion: 2))
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()
        
        let expectation = expectation(description: "Callback")
        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
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
        
        waitForExpectations(timeout: 2)
    }

    func testTokenizeVenmoAccount_whenAppSwitchFails_callsBackWithError() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()

        let expectation = expectation(description: "Callback invoked")
        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
            XCTAssertNil(venmoAccount)
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, "com.braintreepayments.BTVenmoAppSwitchReturnURLErrorDomain")
            expectation.fulfill()
        }
        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/error")!)

        waitForExpectations(timeout: 2)
    }

    func testTokenizeVenmoAccount_vaultTrue_setsShouldVaultProperty() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()

        let expectation = expectation(description: "Callback invoked")

        venmoRequest.vault = true

        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
            XCTAssertTrue(venmoClient.shouldVault)
            expectation.fulfill()
        }

        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        waitForExpectations(timeout: 2)
    }

    func testTokenizeVenmoAccount_vaultFalse_setsVaultToFalse() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()
        
        let expectation = expectation(description: "Callback invoked")
        
        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
            XCTAssertFalse(venmoClient.shouldVault)
            expectation.fulfill()
        }
        
        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        waitForExpectations(timeout: 2)
    }
    
    func testTokenizeVenmoAccount_vaultTrue_callsBackWithNonce() {
        mockAPIClient.authorization = try! BTClientToken(clientToken: TestClientTokenFactory.validClientToken)

        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()
        
        let expectation = expectation(description: "Callback invoked")

        venmoRequest.vault = true

        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
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
            ] as [String: Any]]
        ])

        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        waitForExpectations(timeout: 2)
    }
    
    func testTokenizeVenmoAccount_vaultTrue_sendsSucessAnalyticsEvent() {
        mockAPIClient.authorization = try! BTClientToken(clientToken: TestClientTokenFactory.validClientToken)

        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"

        let expectation = expectation(description: "Callback invoked")

        venmoRequest.vault = true

        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
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
            ] as [String: Any]]
        ])

        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        waitForExpectations(timeout: 2)

        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, BTVenmoAnalytics.tokenizeSucceeded)
        XCTAssertEqual(mockAPIClient.postedPayPalContextID, "some-resource-id")
        XCTAssertEqual(mockAPIClient.postedLinkType, "deeplink")
    }

    func testTokenizeVenmoAccount_fallbackToWebTrue_sendsSuccessAnalyticsEvent() {
        mockAPIClient.authorization = try! BTClientToken(clientToken: TestClientTokenFactory.validClientToken)

        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"

        let expectation = expectation(description: "Callback invoked")

        venmoRequest.fallbackToWeb = true

        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
            XCTAssertNil(error)
            XCTAssertEqual(venmoAccount?.username, "venmojoe")
            XCTAssertEqual(venmoAccount?.nonce, "abcd-venmo-nonce")
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
            ] as [String: Any]]
        ])

        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=abcd-venmo-nonce&username=venmojoe")!)
        waitForExpectations(timeout: 2)

        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, BTVenmoAnalytics.tokenizeSucceeded)
        XCTAssertEqual(mockAPIClient.postedPayPalContextID, "some-resource-id")
        XCTAssertEqual(mockAPIClient.postedLinkType, "universal")
    }

    func testTokenizeVenmoAccount_vaultTrue_sendsFailureAnalyticsEvent() {
        mockAPIClient.authorization = try! BTClientToken(clientToken: TestClientTokenFactory.validClientToken)
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"

        let expectation = expectation(description: "Callback invoked")

        venmoRequest.vault = true

        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }

        mockAPIClient.cannedResponseError = NSError(domain: "Fake Error", code: 400, userInfo: nil)

        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        waitForExpectations(timeout: 2)

        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, BTVenmoAnalytics.tokenizeFailed)
        XCTAssertEqual(mockAPIClient.postedPayPalContextID, "some-resource-id")
        XCTAssertEqual(mockAPIClient.postedLinkType, "deeplink")
    }

    func testTokenizeVenmoAccount_whenAppSwitchCanceled_callsBackWithCancelError() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"

        let expectation = expectation(description: "Callback invoked")
        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
            XCTAssertNil(venmoAccount)
            XCTAssertNotNil(error)
            
            let error = error! as NSError
            XCTAssertEqual(error.localizedDescription, BTVenmoError.canceled.localizedDescription)
            XCTAssertEqual(error.code, 10)
            
            expectation.fulfill()
        }
        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/cancel")!)

        waitForExpectations(timeout: 2)
    }

    func testAuthorizeAccountWithProfileID_withNilProfileID_usesDefaultProfileIDAndAccessTokenFromConfiguration() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoClient.tokenize(venmoRequest) { _, _ in }

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

        venmoClient.tokenize(venmoRequest) { _, _ in }

        XCTAssertTrue(fakeApplication.openURLWasCalled)
        XCTAssertEqual(fakeApplication.lastOpenURL!.scheme, "com.venmo.touch.v2")
        XCTAssertNotNil(fakeApplication.lastOpenURL!.absoluteString.range(of: "second_venmo_merchant_id"));
        XCTAssertNotNil(fakeApplication.lastOpenURL!.absoluteString.range(of: "venmo-access-token"));
    }

    func testTokenizeVenmoAccount_whenIsFinalAmountSetAsTrue_createsPaymentContext() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        venmoRequest.displayName = "app-display-name"
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"

        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoRequest.isFinalAmount = true
        venmoClient.tokenize(venmoRequest) { _, _ in }

        XCTAssertEqual(mockAPIClient.lastPOSTAPIClientHTTPType, .graphQLAPI)
        let params = mockAPIClient.lastPOSTParameters as? NSDictionary
        if let inputDict = params?["variables"] as? NSDictionary,
           let input = inputDict["input"] as? [String:Any] {
            XCTAssertEqual("true", input["isFinalAmount"] as? String)
        }
    }

    func testTokenizeVenmoAccount_whenIsFinalAmountSetAsFalse_createsPaymentContext() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        venmoRequest.displayName = "app-display-name"
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"

        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoRequest.isFinalAmount = false
        venmoClient.tokenize(venmoRequest) { _, _ in }

        XCTAssertEqual(mockAPIClient.lastPOSTAPIClientHTTPType, .graphQLAPI)
        let params = mockAPIClient.lastPOSTParameters as? NSDictionary
        if let inputDict = params?["variables"] as? NSDictionary,
           let input = inputDict["input"] as? [String:Any] {
            XCTAssertEqual("false", input["isFinalAmount"] as? String)
        }
    }

    // MARK: - Analytics
    
    func testAPIClientMetadata_hasIntegrationSetToCustom() {
        // API client by default uses source = .Unknown and integration = .Custom
        let apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")!
        let venmoClient = BTVenmoClient(apiClient: apiClient)
        
        XCTAssertEqual(venmoClient.apiClient.metadata.integration, BTClientMetadataIntegration.custom)
    }

    func testTokenize_whenConfigurationIsInvalid_returnsError() async {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()

        mockAPIClient.cannedConfigurationResponseBody = nil
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"

        do {
            let _ = try await venmoClient.tokenize(venmoRequest)
        } catch {
            let error = error as NSError
            XCTAssertNotNil(error)
            XCTAssertEqual(error.localizedDescription, BTVenmoError.fetchConfigurationFailed.localizedDescription)
        }
    }

    func testTokenize_whenVenmoRequest_setsVaultAnalyticsTag() async {
        let venmoRequest = BTVenmoRequest(paymentMethodUsage: .multiUse)
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        let _ = try? await venmoClient.tokenize(venmoRequest)

        XCTAssertFalse(mockAPIClient.postedIsVaultRequest)
    }
    
    // MARK: - BTAppContextSwitchClient

    func testIsiOSAppSwitchAvailable_whenApplicationCanOpenVenmoURL_returnsTrue() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        fakeApplication.cannedCanOpenURL = false
        fakeApplication.canOpenURLWhitelist.append(URL(string: "com.venmo.touch.v2://x-callback-url/path")!)
        venmoClient.application = fakeApplication

        XCTAssertTrue(venmoClient.isVenmoAppInstalled())
    }

    func testIsiOSAppSwitchAvailable_whenApplicationCantOpenVenmoURL_returnsFalse() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        fakeApplication.cannedCanOpenURL = false
        venmoClient.application = fakeApplication

        XCTAssertFalse(venmoClient.isVenmoAppInstalled())
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

        let expectation = expectation(description: "Callback invoked")
        let venmoRequest = BTVenmoRequest(paymentMethodUsage: .multiUse)
        venmoRequest.vault = true

        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
            XCTAssertNil(error)

            XCTAssertEqual(venmoAccount?.username, "venmotim")
            XCTAssertEqual(venmoAccount?.nonce, "lmnop-venmo-nonce")
            XCTAssertFalse(venmoAccount!.isDefault)

            expectation.fulfill()
        }

        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=lmnop-venmo-nonce&username=venmotim")!)
        waitForExpectations(timeout: 2)

        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, BTVenmoAnalytics.tokenizeSucceeded)
        XCTAssertEqual(mockAPIClient.postedPayPalContextID, "some-resource-id")
    }

    // Note: testing of handleReturnURL is done implicitly while testing authorizeAccountWithCompletion

    // MARK: - openVenmoAppPageInAppStore

    func testGotoVenmoInAppStore_opensVenmoAppStoreURL() {
        let venmoClient = BTVenmoClient(apiClient: mockAPIClient)
        BTAppContextSwitcher.sharedInstance.returnURLScheme = "scheme"
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoClient.openVenmoAppPageInAppStore()

        XCTAssertTrue(fakeApplication.openURLWasCalled)
        XCTAssertEqual(fakeApplication.lastOpenURL!.absoluteString, "https://itunes.apple.com/us/app/venmo-send-receive-money/id351727428")
    }
}
