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
        venmoRequest.discountAmount = "9"
        venmoRequest.taxAmount = "9"
        venmoRequest.shippingAmount = "9"
        let lineItem = BTVenmoLineItem(
            quantity: 1,
            unitAmount: "9",
            name: "name",
            kind: .debit,
            unitTaxAmount: "1",
            itemDescription: "some-description",
            productCode: "some-product-code",
            url: URL(string: "some.fake.url")!
        )
        venmoRequest.lineItems = [lineItem]
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
            
            if let paysheetDetails = input["paysheetDetails"] as? [String: Any] {
                XCTAssertEqual("false",paysheetDetails["collectCustomerShippingAddress"] as? String)
                XCTAssertEqual("false",paysheetDetails["collectCustomerBillingAddress"] as? String)
                
                if let transactionDetailsString = paysheetDetails["transactionDetails"] as? [String: Any] {
                    XCTAssertEqual(transactionDetailsString["totalAmount"] as? String, "9")
                    XCTAssertEqual(transactionDetailsString["subTotalAmount"] as? String, "9")
                    XCTAssertEqual(transactionDetailsString["discountAmount"] as? String, "9")
                    XCTAssertEqual(transactionDetailsString["taxAmount"] as? String, "9")
                    XCTAssertEqual(transactionDetailsString["shippingAmount"] as? String, "9")
                    if let lineItems = transactionDetailsString["lineItems"] as? [[String: Any]] {
                        XCTAssertEqual(lineItems.first?["quantity"] as? Int, 1)
                        XCTAssertEqual(lineItems.first?["name"] as? String, "name")
                        XCTAssertEqual(lineItems.first?["unitAmount"] as? String, "9")
                        XCTAssertEqual(lineItems.first?["type"] as? String, "DEBIT")
                        XCTAssertEqual(lineItems.first?["unitTaxAmount"] as? String, "1")
                        XCTAssertEqual(lineItems.first?["description"] as? String, "some-description")
                        XCTAssertEqual(lineItems.first?["productCode"] as? String, "some-product-code")
                        XCTAssertEqual(lineItems.first?["url"] as? String, "some.fake.url")
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

        XCTAssertEqual(urlComponents.scheme, "https")
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "braintree_merchant_id", value: "venmo_merchant_id")))
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "braintree_access_token", value: "venmo-access-token")))
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "braintree_environment", value: "sandbox")))
    }

    func testTokenizeVenmoAccount_whenReturnURLContainsPaymentContextID_getsResultFromPaymentContext() {
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

        DispatchQueue.main.async {
            BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?resource_id=12345")!)
        }

        waitForExpectations(timeout: 1)
    }

    func testTokenizeVenmoAccount_whenReturnURLContainsPaymentContextID_andFetchPaymentContextFails_returnsError() {
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

        DispatchQueue.main.async {
            BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?resource_id=12345")!)
        }

        waitForExpectations(timeout: 1)
    }

    func testTokenizeVenmoAccount_whenUsingTokenizationKeyAndAppSwitchSucceeds_tokenizesVenmoAccount() {
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
        
        DispatchQueue.main.async {
            BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        }

        waitForExpectations(timeout: 2)
    }
    
    func testTokenizeVenmoAccount_whenUsingClientTokenAndAppSwitchSucceeds_tokenizesVenmoAccount() {
        // Test setup sets up mockAPIClient with a tokenization key, we want a client token
        mockAPIClient.authorization = try! BTClientToken(clientToken: TestClientTokenFactory.token(withVersion: 2))
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
        
        DispatchQueue.main.async {
            BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        }
        
        waitForExpectations(timeout: 2)
    }

    func testTokenizeVenmoAccount_whenAppSwitchFails_callsBackWithError() {
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()

        let expectation = expectation(description: "Callback invoked")
        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
            XCTAssertNil(venmoAccount)
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, "com.braintreepayments.BTVenmoAppSwitchReturnURLErrorDomain")
            expectation.fulfill()
        }
        
        DispatchQueue.main.async {
            BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/error")!)
        }

        waitForExpectations(timeout: 2)
    }

    func testTokenizeVenmoAccount_vaultTrue_setsShouldVaultProperty() {
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()

        let expectation = expectation(description: "Callback invoked")

        venmoRequest.vault = true

        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
            XCTAssertTrue(self.venmoClient.shouldVault)
            expectation.fulfill()
        }

        DispatchQueue.main.async {
            BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        }
        
        waitForExpectations(timeout: 2)
    }

    func testTokenizeVenmoAccount_vaultFalse_setsVaultToFalse() {
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()
        
        let expectation = expectation(description: "Callback invoked")
        
        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
            XCTAssertFalse(self.venmoClient.shouldVault)
            expectation.fulfill()
        }
        
        DispatchQueue.main.async {
            BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        }
        
        waitForExpectations(timeout: 2)
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

        DispatchQueue.main.async {
            BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        }
        
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

        DispatchQueue.main.async {
            BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        }
        
        waitForExpectations(timeout: 2)

        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, BTVenmoAnalytics.tokenizeSucceeded)
        XCTAssertEqual(mockAPIClient.postedContextID, "some-resource-id")
    }

    func testTokenizeVenmoAccount_vaultTrue_sendsFailureAnalyticsEvent() {
        mockAPIClient.authorization = try! BTClientToken(clientToken: TestClientTokenFactory.validClientToken)
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()

        let expectation = expectation(description: "Callback invoked")

        venmoRequest.vault = true

        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }

        mockAPIClient.cannedResponseError = NSError(domain: "Fake Error", code: 400, userInfo: nil)

        DispatchQueue.main.async {
            BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        }
        
        waitForExpectations(timeout: 2)

        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, BTVenmoAnalytics.tokenizeFailed)
        XCTAssertEqual(mockAPIClient.postedContextID, "some-resource-id")
    }

    func testTokenizeVenmoAccount_whenAppSwitchCanceled_callsBackWithCancelError() {
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()

        let expectation = expectation(description: "Callback invoked")
        venmoClient.tokenize(venmoRequest) { venmoAccount, error in
            XCTAssertNil(venmoAccount)
            XCTAssertNotNil(error)
            
            let error = error! as NSError
            XCTAssertEqual(error.localizedDescription, BTVenmoError.canceled.localizedDescription)
            XCTAssertEqual(error.code, 9)
            
            expectation.fulfill()
        }
        
        DispatchQueue.main.async {
            BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/cancel")!)
        }

        waitForExpectations(timeout: 2)
    }

    func testAuthorizeAccountWithProfileID_withNilProfileID_usesDefaultProfileIDAndAccessTokenFromConfiguration() {
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoClient.tokenize(venmoRequest) { _, _ in }

        XCTAssertTrue(fakeApplication.openURLWasCalled)
        XCTAssertEqual(fakeApplication.lastOpenURL!.scheme, "https")
        XCTAssertNotNil(fakeApplication.lastOpenURL!.absoluteString.range(of: "venmo_merchant_id"));
        XCTAssertNotNil(fakeApplication.lastOpenURL!.absoluteString.range(of: "venmo-access-token"));
    }

    func testAuthorizeAccountWithProfileID_withProfileID_usesProfileIDToAppSwitch() {
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoRequest.profileID = "second_venmo_merchant_id"

        venmoClient.tokenize(venmoRequest) { _, _ in }

        XCTAssertTrue(fakeApplication.openURLWasCalled)
        XCTAssertEqual(fakeApplication.lastOpenURL!.scheme, "https")
        XCTAssertNotNil(fakeApplication.lastOpenURL!.absoluteString.range(of: "second_venmo_merchant_id"));
        XCTAssertNotNil(fakeApplication.lastOpenURL!.absoluteString.range(of: "venmo-access-token"));
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

        DispatchQueue.main.async {
            BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=lmnop-venmo-nonce&username=venmotim")!)
        }
        
        waitForExpectations(timeout: 2)

        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, BTVenmoAnalytics.tokenizeSucceeded)
        XCTAssertEqual(mockAPIClient.postedContextID, "some-resource-id")
    }

    // Note: testing of handleReturnURL is done implicitly while testing authorizeAccountWithCompletion

    // MARK: - openVenmoAppPageInAppStore

    func testGotoVenmoInAppStore_opensVenmoAppStoreURL() {
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoClient.openVenmoAppPageInAppStore()

        XCTAssertTrue(fakeApplication.openURLWasCalled)
        XCTAssertEqual(fakeApplication.lastOpenURL!.absoluteString, "https://itunes.apple.com/us/app/venmo-send-receive-money/id351727428")
    }
}
