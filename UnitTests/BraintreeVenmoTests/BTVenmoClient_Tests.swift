import XCTest
import UIKit
@testable import BraintreeVenmo
@testable import BraintreeCore
@testable import BraintreeTestShared

class BTVenmoClient_Tests: XCTestCase {
    var mockAPIClient : MockAPIClient = MockAPIClient(authorization: "development_tokenization_key")
    var venmoRequest: BTVenmoRequest = BTVenmoRequest(paymentMethodUsage: .multiUse)
    var venmoClient: BTVenmoClient!

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")
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

        venmoClient = BTVenmoClient(
            authorization: "sandbox_9dbg82cq_dcpspy2brwdjr3qn",
            universalLink: URL(string: "https://mywebsite.com/braintree-payments")!
        )
        
        venmoClient.apiClient = mockAPIClient
    }

    func testTokenize_whenRemoteConfigurationFetchFails_callsBackWithConfigurationError() {
        mockAPIClient.cannedConfigurationResponseError = NSError(domain: "", code: 0, userInfo: nil)

        let expectation = expectation(description: "Tokenize fails with error")
        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
            XCTAssertEqual(error! as NSError, self.mockAPIClient.cannedConfigurationResponseError!)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testTokenizeVenmoAccount_whenVenmoConfigurationDisabled_callsBackWithError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [:] as [String: Any?])

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

        let expectation = expectation(description: "tokenization callback")
        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTVenmoError.errorDomain)
            XCTAssertEqual(error.code, BTVenmoError.disabled.errorCode)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)
    }

    func testTokenizeVenmoAccount_whenPaymentMethodUsageSet_createsPaymentContext() {
        venmoRequest.displayName = "app-display-name"
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

        venmoRequest.collectCustomerBillingAddress = true
        venmoRequest.collectCustomerShippingAddress = true
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
        venmoRequest.collectCustomerBillingAddress = true
        venmoRequest.collectCustomerShippingAddress = true

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
        venmoRequest.subTotalAmount = "9"
        venmoRequest.totalAmount = "9"
        venmoRequest.lineItems = [BTVenmoLineItem(quantity: 1, unitAmount: "9", name: "name", kind: .debit)]
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
        let expectation = expectation(description: "Wait for Venmo app switch")

        let fakeApplication = FakeApplication()
        fakeApplication.onOpenURL = {
            expectation.fulfill()
        }

        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoClient.tokenize(venmoRequest) { _, _ in }

        wait(for: [expectation], timeout: 2.0)

        XCTAssertTrue(fakeApplication.openURLWasCalled)

        guard let url = fakeApplication.lastOpenURL,
              let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = urlComponents.queryItems else {
            XCTFail("Failed to extract URL components or query items")
            return
        }

        XCTAssertEqual(urlComponents.scheme, "https")
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "braintree_merchant_id", value: "venmo_merchant_id")))
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "braintree_access_token", value: "venmo-access-token")))
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "braintree_environment", value: "sandbox")))
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "resource_id", value: "some-resource-id")))
    }


    func testTokenizeVenmoAccount_whenCannotParsePaymentContextID_callsBackWithError() {
        mockAPIClient.cannedResponseBody = BTJSON(value: ["random":["lady_gaga":"poker_face"]])

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
        let expectation = expectation(description: "Wait for Venmo app switch")

        let fakeApplication = FakeApplication()
        fakeApplication.onOpenURL = {
            expectation.fulfill()
        }

        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoClient.tokenize(venmoRequest) { _, _ in }

        wait(for: [expectation], timeout: 2.0)

        guard let url = fakeApplication.lastOpenURL,
              let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = urlComponents.queryItems else {
            XCTFail("URL or query items were nil")
            return
        }

        XCTAssertTrue(fakeApplication.openURLWasCalled)
        XCTAssertEqual(urlComponents.scheme, "https")
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "braintree_merchant_id", value: "venmo_merchant_id")))
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "braintree_access_token", value: "venmo-access-token")))
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "braintree_environment", value: "sandbox")))
    }


    func testTokenizeVenmoAccount_whenReturnURLContainsPaymentContextID_getsResultFromPaymentContext() {
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "data": [
                "node": [
                    "paymentMethodId": "fake-venmo-nonce",
                    "userName": "fake-venmo-username"
                ]
            ]
        ])

        let expectation = expectation(description: "Callback")

        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
            XCTAssertNil(error)
            XCTAssertEqual(venmoAccount?.nonce, "fake-venmo-nonce")
            XCTAssertEqual(venmoAccount?.username, "fake-venmo-username")
            expectation.fulfill()
        }
        
        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?resource_id=12345")!)

        wait(for: [expectation], timeout: 1.0)
    }


    func testTokenizeVenmoAccount_whenReturnURLContainsPaymentContextID_andFetchPaymentContextFails_returnsError() {
        let appSwitchExpectation = expectation(description: "App switch invoked")
        let completionExpectation = expectation(description: "Callback")

        let fakeApplication = FakeApplication()
        fakeApplication.onOpenURL = {
            appSwitchExpectation.fulfill()
        }

        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
            XCTAssertNotNil(error)
            XCTAssertNil(venmoAccount?.nonce)
            XCTAssertNil(venmoAccount?.username)
            completionExpectation.fulfill()
        }

        // Set the canned error response before simulating the return
        mockAPIClient.cannedResponseBody = nil
        mockAPIClient.cannedResponseError = NSError(domain: "some-domain", code: 1, userInfo: nil)

        // Wait for app switch to be triggered
        wait(for: [appSwitchExpectation], timeout: 1.0)

        // Simulate app switch return with resource ID
        let returnURL = URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?resource_id=12345")!
        BTVenmoClient.handleReturnURL(returnURL)

        wait(for: [completionExpectation], timeout: 1.0)
    }


    func testTokenizeVenmoAccount_whenUsingTokenizationKeyAndAppSwitchSucceeds_tokenizesVenmoAccount() {
        let appSwitchExpectation = expectation(description: "App switch invoked")
        let completionExpectation = expectation(description: "Callback")

        let fakeApplication = FakeApplication()
        fakeApplication.onOpenURL = {
            appSwitchExpectation.fulfill()
        }

        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
            guard let venmoAccount = venmoAccount else {
                XCTFail("Received an error: \(String(describing: error))")
                return
            }

            XCTAssertNil(error)
            XCTAssertEqual(venmoAccount.nonce, "fake-nonce")
            XCTAssertEqual(venmoAccount.username, "fake-username")
            completionExpectation.fulfill()
        }

        // Wait for app switch to complete
        wait(for: [appSwitchExpectation], timeout: 1.0)

        // Simulate successful return from Venmo app
        let returnURL = URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!
        BTVenmoClient.handleReturnURL(returnURL)

        // Wait for the completion callback
        wait(for: [completionExpectation], timeout: 1.0)
    }

    
    func testTokenizeVenmoAccount_whenUsingClientTokenAndAppSwitchSucceeds_tokenizesVenmoAccount() {
        // Replace tokenization key with client token
        mockAPIClient.authorization = try! BTClientToken(clientToken: TestClientTokenFactory.token(withVersion: 2))

        let appSwitchExpectation = expectation(description: "App switch invoked")
        let completionExpectation = expectation(description: "Callback")

        let fakeApplication = FakeApplication()
        fakeApplication.onOpenURL = {
            appSwitchExpectation.fulfill()
        }

        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
            guard let venmoAccount = venmoAccount else {
                XCTFail("Received an error: \(String(describing: error))")
                return
            }

            XCTAssertNil(error)
            XCTAssertEqual(venmoAccount.nonce, "fake-nonce")
            XCTAssertEqual(venmoAccount.username, "fake-username")
            completionExpectation.fulfill()
        }

        // Wait until app switch is triggered before simulating return
        wait(for: [appSwitchExpectation], timeout: 1.0)

        // Simulate successful app switch return
        let returnURL = URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!
        BTVenmoClient.handleReturnURL(returnURL)

        wait(for: [completionExpectation], timeout: 1.0)
    }


    func testTokenizeVenmoAccount_whenAppSwitchFails_callsBackWithError() {
        let appSwitchExpectation = expectation(description: "App switch invoked")
        let completionExpectation = expectation(description: "Callback invoked")

        let fakeApplication = FakeApplication()
        fakeApplication.onOpenURL = {
            appSwitchExpectation.fulfill()
        }

        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
            XCTAssertNil(venmoAccount)

            guard let error = error as NSError? else {
                XCTFail("Expected error to be non-nil")
                return
            }

            XCTAssertEqual(error.domain, "com.braintreepayments.BTVenmoAppSwitchReturnURLErrorDomain")
            completionExpectation.fulfill()
        }

        // Wait for the tokenize setup and app switch to complete
        wait(for: [appSwitchExpectation], timeout: 1.0)

        // Simulate error return from Venmo app
        let errorURL = URL(string: "scheme://x-callback-url/vzero/auth/venmo/error")!
        BTVenmoClient.handleReturnURL(errorURL)

        wait(for: [completionExpectation], timeout: 1.0)
    }


    func testTokenizeVenmoAccount_vaultTrue_setsShouldVaultProperty() {
        let appSwitchExpectation = expectation(description: "App switch invoked")
        let completionExpectation = expectation(description: "Callback invoked")

        let fakeApplication = FakeApplication()
        fakeApplication.onOpenURL = {
            appSwitchExpectation.fulfill()
        }

        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoRequest.vault = true

        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
            XCTAssertTrue(self.venmoClient.shouldVault)
            completionExpectation.fulfill()
        }

        // Wait until the app switch is triggered
        wait(for: [appSwitchExpectation], timeout: 1.0)

        // Simulate Venmo app return
        let returnURL = URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!
        BTVenmoClient.handleReturnURL(returnURL)

        // Wait for the callback to complete
        wait(for: [completionExpectation], timeout: 1.0)
    }


    func testTokenizeVenmoAccount_vaultFalse_setsVaultToFalse() {
        let appSwitchExpectation = expectation(description: "App switch invoked")
        let completionExpectation = expectation(description: "Callback invoked")

        let fakeApplication = FakeApplication()
        fakeApplication.onOpenURL = {
            appSwitchExpectation.fulfill()
        }

        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
            XCTAssertFalse(self.venmoClient.shouldVault)
            completionExpectation.fulfill()
        }

        // Wait for the app switch to be triggered before simulating return
        wait(for: [appSwitchExpectation], timeout: 1.0)

        // Simulate app switch return from Venmo
        let returnURL = URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!
        BTVenmoClient.handleReturnURL(returnURL)

        wait(for: [completionExpectation], timeout: 1.0)
    }
    
    func testTokenizeVenmoAccount_vaultTrue_callsBackWithNonce() {
        mockAPIClient.authorization = try! BTClientToken(clientToken: TestClientTokenFactory.validClientToken)

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

        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, BTVenmoAnalytics.tokenizeSucceeded)
        XCTAssertEqual(mockAPIClient.postedPayPalContextID, "some-resource-id")
    }

    func testTokenizeVenmoAccount_vaultTrue_sendsFailureAnalyticsEvent() {
        mockAPIClient.authorization = try! BTClientToken(clientToken: TestClientTokenFactory.validClientToken)

        let appSwitchExpectation = expectation(description: "App switch invoked")
        let completionExpectation = expectation(description: "Callback invoked")

        let fakeApplication = FakeApplication()
        fakeApplication.onOpenURL = {
            appSwitchExpectation.fulfill()
        }

        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoRequest.vault = true

        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
            XCTAssertNotNil(error)
            completionExpectation.fulfill()
        }

        // Simulate server failure on vaulting the Venmo account
        mockAPIClient.cannedResponseError = NSError(domain: "Fake Error", code: 400, userInfo: nil)

        wait(for: [appSwitchExpectation], timeout: 1.0)

        // Simulate app switch return from Venmo
        let returnURL = URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!
        BTVenmoClient.handleReturnURL(returnURL)

        wait(for: [completionExpectation], timeout: 1.0)

        // ✅ Assert failure analytics
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last, BTVenmoAnalytics.tokenizeFailed)
        XCTAssertEqual(mockAPIClient.postedPayPalContextID, "some-resource-id")
    }


    func testTokenizeVenmoAccount_whenAppSwitchCanceled_callsBackWithCancelError() {
        let appSwitchExpectation = expectation(description: "App switch invoked")
        let completionExpectation = expectation(description: "Callback invoked")

        let fakeApplication = FakeApplication()
        fakeApplication.onOpenURL = {
            appSwitchExpectation.fulfill()
        }

        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
            XCTAssertNil(venmoAccount)
            XCTAssertNotNil(error)

            let nsError = error! as NSError
            XCTAssertEqual(nsError.localizedDescription, BTVenmoError.canceled.localizedDescription)
            XCTAssertEqual(nsError.code, 9)

            completionExpectation.fulfill()
        }

        // Wait for the app switch to complete before handling return URL
        wait(for: [appSwitchExpectation], timeout: 1.0)

        // Simulate cancel return URL
        let cancelURL = URL(string: "scheme://x-callback-url/vzero/auth/venmo/cancel")!
        BTVenmoClient.handleReturnURL(cancelURL)

        wait(for: [completionExpectation], timeout: 1.0)
    }


    func testAuthorizeAccountWithProfileID_withNilProfileID_usesDefaultProfileIDAndAccessTokenFromConfiguration() {
        let expectation = self.expectation(description: "Wait for openURL completion")

        let fakeApplication = FakeApplication()
        fakeApplication.onOpenURL = {
            expectation.fulfill()
        }

        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoClient.tokenize(venmoRequest) { _, _ in
            /* This block likely runs before the main-actor completion fires
            So we rely on onOpenURL to fulfill expectation instead */
        }

        wait(for: [expectation], timeout: 2.0)

        XCTAssertTrue(fakeApplication.openURLWasCalled)
        XCTAssertEqual(fakeApplication.lastOpenURL?.scheme, "https")
        XCTAssertNotNil(fakeApplication.lastOpenURL?.absoluteString.range(of: "venmo_merchant_id"))
        XCTAssertNotNil(fakeApplication.lastOpenURL?.absoluteString.range(of: "venmo-access-token"))
    }

    func testAuthorizeAccountWithProfileID_withProfileID_usesProfileIDToAppSwitch() {
        let expectation = self.expectation(description: "Wait for app switch to be triggered")

        let fakeApplication = FakeApplication()
        fakeApplication.onOpenURL = {
            expectation.fulfill()
        }

        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoRequest.profileID = "second_venmo_merchant_id"

        venmoClient.tokenize(venmoRequest) { _, _ in }

        wait(for: [expectation], timeout: 2.0)

        XCTAssertTrue(fakeApplication.openURLWasCalled)
        XCTAssertEqual(fakeApplication.lastOpenURL?.scheme, "https")
        XCTAssertNotNil(fakeApplication.lastOpenURL?.absoluteString.range(of: "second_venmo_merchant_id"))
        XCTAssertNotNil(fakeApplication.lastOpenURL?.absoluteString.range(of: "venmo-access-token"))
    }


    func testTokenizeVenmoAccount_whenIsFinalAmountSetAsTrue_createsPaymentContext() {
        venmoRequest.displayName = "app-display-name"

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
        venmoRequest.displayName = "app-display-name"

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
        let venmoClient = BTVenmoClient(
            authorization: "development_testing_integration_merchant_id",
            universalLink: URL(string: "https://mywebsite.com/braintree-payments")!
        )

        // API client by default uses source = .Unknown and integration = .Custom
        XCTAssertEqual(venmoClient.apiClient.metadata.integration, BTClientMetadataIntegration.custom)
    }

    func testTokenize_whenConfigurationIsInvalid_returnsError() async {
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()

        mockAPIClient.cannedConfigurationResponseBody = nil

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
        let _ = try? await venmoClient.tokenize(venmoRequest)

        XCTAssertFalse(mockAPIClient.postedIsVaultRequest)
    }
    
    func testHandleOpen_sendsHandleReturnStartedEvent() {
        let appSwitchURL = URL(string: "some-url")!
        venmoClient.handleOpen(appSwitchURL)
        
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, BTVenmoAnalytics.handleReturnStarted)
    }
    
    @MainActor
    func testStartVenmoFlow_sendsAppSwitchStartedEvent() {
        let appSwitchURL = URL(string: "some-url")!
        venmoClient.startVenmoFlow(with: appSwitchURL, shouldVault: false) { _, _ in }
        
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, BTVenmoAnalytics.appSwitchStarted)
    }
    
    func testInvokedOpenURLSuccessfully_whenSuccess_sendsAppSwitchSucceeded_withAppSwitchURL() {
        let eventName = BTVenmoAnalytics.appSwitchSucceeded
        let appSwitchURL = URL(string: "some-url")!
        venmoClient.invokedOpenURLSuccessfully(true, shouldVault: true, appSwitchURL: appSwitchURL) { _, _ in }
        
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, eventName)
        XCTAssertEqual(mockAPIClient.postedAppSwitchURL[eventName], appSwitchURL.absoluteString)
    }
    
    func testInvokedOpenURLSuccessfully_whenFailure_sendsAppSwitchFailed_withAppSwitchURL() {
        let eventName = BTVenmoAnalytics.appSwitchFailed
        let appSwitchURL = URL(string: "some-url")!
        venmoClient.invokedOpenURLSuccessfully(false, shouldVault: true, appSwitchURL: appSwitchURL) { _, _ in }
        
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.first!, eventName)
        XCTAssertEqual(mockAPIClient.postedAppSwitchURL[eventName], appSwitchURL.absoluteString)
    }
    
    // MARK: - BTAppContextSwitchClient

    func testCanHandleReturnURL_withValidHost_andValidPath_returnsTrue() {
        XCTAssertTrue(BTVenmoClient.canHandleReturnURL(URL(string: "https://www.braintreesample.com/braintreeAppSwitchVenmo/success")!))
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

    @MainActor
    func testGotoVenmoInAppStore_opensVenmoAppStoreURL() {
        let expectation = expectation(description: "Wait for app store open")

        let fakeApplication = FakeApplication()
        fakeApplication.onOpenURL = {
            expectation.fulfill()
        }

        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoClient.openVenmoAppPageInAppStore()

        wait(for: [expectation], timeout: 2.0)

        XCTAssertTrue(fakeApplication.openURLWasCalled)
        XCTAssertEqual(
            fakeApplication.lastOpenURL?.absoluteString,
            "https://itunes.apple.com/us/app/venmo-send-receive-money/id351727428"
        )
    }

}
