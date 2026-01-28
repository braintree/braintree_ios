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

    func testTokenize_whenRemoteConfigurationFetchFails_throwsConfigurationError() async {
        mockAPIClient.cannedConfigurationResponseError = NSError(domain: "", code: 0, userInfo: nil)

        do {
            let _ = try await venmoClient.tokenize(venmoRequest)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as NSError, mockAPIClient.cannedConfigurationResponseError!)
        }
    }

    func testTokenizeVenmoAccount_whenVenmoConfigurationDisabled_throwsError() async {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [:] as [String: Any?])

        do {
            let _ = try await venmoClient.tokenize(venmoRequest)
            XCTFail("Expected error to be thrown")
        } catch {
            guard let error = error as NSError? else {
                XCTFail("Error should be NSError")
                return
            }
            XCTAssertEqual(error.domain, BTVenmoError.errorDomain)
            XCTAssertEqual(error.code, BTVenmoError.disabled.errorCode)
        }
    }

    func testTokenizeVenmoAccount_whenVenmoConfigurationMissing_throwsError() async {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [:] as [String: Any?])

        do {
            let _ = try await venmoClient.tokenize(venmoRequest)
            XCTFail("Expected error to be thrown")
        } catch {
            guard let error = error as NSError? else {
                XCTFail("Error should be NSError")
                return
            }
            XCTAssertEqual(error.domain, BTVenmoError.errorDomain)
            XCTAssertEqual(error.code, BTVenmoError.disabled.errorCode)
        }
    }

    func testTokenizeVenmoAccount_whenPaymentMethodUsageSet_createsPaymentContext() async {
        let venmoRequest = BTVenmoRequest(paymentMethodUsage: .multiUse, displayName: "app-display-name")
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        let _ = try? await venmoClient.tokenize(venmoRequest)

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

    func testTokenizeVenmoAccount_whenDisplayNameNotSet_createsPaymentContextWithoutDisplayName() async {
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        let _ = try? await venmoClient.tokenize(venmoRequest)

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
    
    func testTokenizeVenmoAccount_whenEnrichedCustomerDataDisabled_doesNotAllowCollectingAddresses() async {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "payWithVenmo" : [
                "environment": "sandbox",
                "merchantId": "venmo_merchant_id",
                "accessToken": "venmo-access-token",
                "enrichedCustomerDataEnabled": false
            ]
        ])
        
        let venmoRequest = BTVenmoRequest(
            paymentMethodUsage: .multiUse,
            collectCustomerBillingAddress: true,
            collectCustomerShippingAddress: true
        )
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        do {
            let _ = try await venmoClient.tokenize(venmoRequest)
            XCTFail("Expected error to be thrown")
        } catch {
            guard let error = error as NSError? else {
                XCTFail("Error should be NSError")
                return
            }
            XCTAssertEqual(error.code, BTVenmoError.enrichedCustomerDataDisabled.errorCode)
        }
    }

    func testTokenizeVenmoAccount_whenCollectAddressFlagsSet_createsPaymentContextWithTheRightFlags() async {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "payWithVenmo" : [
                "environment": "sandbox",
                "merchantId": "venmo_merchant_id",
                "accessToken": "venmo-access-token",
                "enrichedCustomerDataEnabled": true
            ]
        ])
        
        let venmoRequest = BTVenmoRequest(
            paymentMethodUsage: .multiUse,
            collectCustomerBillingAddress: true,
            collectCustomerShippingAddress: true
        )

        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        let _ = try? await venmoClient.tokenize(venmoRequest)
        
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
    
    func testTokenizeVenmoAccount_withAmountsAndLineItemsSet_createsPaymentContext() async {
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
        
        let venmoRequest = BTVenmoRequest(
            paymentMethodUsage: .multiUse,
            subTotalAmount: "9",
            discountAmount: "9",
            taxAmount: "9",
            shippingAmount: "9",
            totalAmount: "9",
            lineItems: [lineItem]
        )
        
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        let _ = try? await venmoClient.tokenize(venmoRequest)
        
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
    
    func testTokenize_withoutLineItems_createsPaymentContextWithoutTransactionDetails() async {
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        let _ = try? await venmoClient.tokenize(venmoRequest)
        
        XCTAssertEqual(mockAPIClient.lastPOSTAPIClientHTTPType, .graphQLAPI)
        
        let params = mockAPIClient.lastPOSTParameters as! [String: Any]
        let queryParams = params["query"] as! String
        XCTAssertTrue(queryParams.contains("mutation CreateVenmoPaymentContext"))
        
        let inputParams = (params["variables"] as! [String: [String: Any]])["input"]
        let paysheetDetails = inputParams?["paysheetDetails"] as! [String: Any]
        XCTAssertNil(paysheetDetails["transactionDetails"])
    }

    func testTokenizeVenmoAccount_opensVenmoURLWithPaymentContextID() async {
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        let _ = try? await venmoClient.tokenize(venmoRequest)

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

    func testTokenizeVenmoAccount_whenCannotParsePaymentContextID_throwsError() async {
        mockAPIClient.cannedResponseBody = BTJSON(value: ["random":["lady_gaga":"poker_face"]])

        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        do {
            let _ = try await venmoClient.tokenize(venmoRequest)
            XCTFail("Expected error to be thrown")
        } catch {
            guard let error = error as NSError? else {
                XCTFail("Error should be NSError")
                return
            }
            XCTAssertEqual(error.domain, "com.braintreepayments.BTVenmoErrorDomain")
            XCTAssertEqual(error.code, BTVenmoError.invalidRedirectURL("").errorCode)
            XCTAssertEqual(error.localizedDescription, "Failed to parse a Venmo paymentContextID while constructing the requestURL. Please contact support.")
        }
    }

    func testTokenizeVenmoAccount_whenFetchPaymentContextIDFails_throwsError() async {
        mockAPIClient.cannedResponseError = NSError(domain: "Venmo Error", code: 100, userInfo: nil)

        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        do {
            let _ = try await venmoClient.tokenize(venmoRequest)
            XCTFail("Expected error to be thrown")
        } catch {
            guard let error = error as NSError? else {
                XCTFail("Error should be NSError")
                return
            }
            XCTAssertEqual(error.domain, "com.braintreepayments.BTVenmoErrorDomain")
            XCTAssertEqual(error.code, BTVenmoError.invalidRedirectURL("").errorCode)
            XCTAssertEqual(error.localizedDescription, "Failed to fetch a Venmo paymentContextID while constructing the requestURL.")
        }
    }

    func testTokenizeVenmoAccount_whenVenmoIsEnabledInControlPanelAndConfiguredCorrectly_opensVenmoURLWithParams() async {
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        let _ = try? await venmoClient.tokenize(venmoRequest)

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

    func testTokenizeVenmoAccount_whenReturnURLContainsPaymentContextID_getsResultFromPaymentContext() async {
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()

        Task {
            do {
                let venmoAccount = try await venmoClient.tokenize(venmoRequest)
                XCTAssertEqual(venmoAccount.nonce, "fake-venmo-nonce")
                XCTAssertEqual(venmoAccount.username, "fake-venmo-username")
            } catch {
                XCTFail("Expected success, got error: \(error)")
            }
        }

        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "data": [
                "node": [
                    "paymentMethodId": "fake-venmo-nonce",
                    "userName": "fake-venmo-username"
                ]
            ]
        ])

        // Wait a bit for the tokenize to initiate
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?resource_id=12345")!)
        
        // Wait for async operations to complete
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
    }

    func testTokenizeVenmoAccount_whenReturnURLContainsPaymentContextID_andFetchPaymentContextFails_throwsError() async {
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()

        Task {
            do {
                let _ = try await venmoClient.tokenize(venmoRequest)
                XCTFail("Expected error to be thrown")
            } catch {
                XCTAssertNotNil(error)
            }
        }

        mockAPIClient.cannedResponseBody = nil
        mockAPIClient.cannedResponseError = NSError(domain: "some-domain", code: 1, userInfo: nil)

        // Wait a bit for the tokenize to initiate
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?resource_id=12345")!)
        
        // Wait for async operations to complete
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
    }

    func testTokenizeVenmoAccount_whenUsingTokenizationKeyAndAppSwitchSucceeds_tokenizesVenmoAccount() async {
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()

        Task {
            do {
                let venmoAccount = try await venmoClient.tokenize(venmoRequest)
                XCTAssertEqual(venmoAccount.nonce, "fake-nonce")
                XCTAssertEqual(venmoAccount.username, "fake-username")
            } catch {
                XCTFail("Expected success, got error: \(error)")
            }
        }
        
        // Wait a bit for the tokenize to initiate
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        
        // Wait for async operations to complete
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
    }
    
    func testTokenizeVenmoAccount_whenUsingClientTokenAndAppSwitchSucceeds_tokenizesVenmoAccount() async {
        // Test setup sets up mockAPIClient with a tokenization key, we want a client token
        mockAPIClient.authorization = try! BTClientToken(clientToken: TestClientTokenFactory.token(withVersion: 2))
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()
        
        Task {
            do {
                let venmoAccount = try await venmoClient.tokenize(venmoRequest)
                XCTAssertEqual(venmoAccount.nonce, "fake-nonce")
                XCTAssertEqual(venmoAccount.username, "fake-username")
            } catch {
                XCTFail("Expected success, got error: \(error)")
            }
        }
        
        // Wait a bit for the tokenize to initiate
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        
        // Wait for async operations to complete
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
    }

    func testTokenizeVenmoAccount_whenAppSwitchFails_throwsError() async {
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()

        Task {
            do {
                let _ = try await venmoClient.tokenize(venmoRequest)
                XCTFail("Expected error to be thrown")
            } catch {
                guard let error = error as NSError? else {
                    XCTFail("Error should be NSError")
                    return
                }
                XCTAssertEqual(error.domain, "com.braintreepayments.BTVenmoAppSwitchReturnURLErrorDomain")
            }
        }
        
        // Wait a bit for the tokenize to initiate
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/error")!)
        
        // Wait for async operations to complete
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
    }

    func testTokenizeVenmoAccount_vaultTrue_setsShouldVaultProperty() async {
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()

        venmoRequest.vault = true

        Task {
            do {
                let _ = try await venmoClient.tokenize(venmoRequest)
                XCTAssertTrue(venmoClient.shouldVault)
            } catch {
                XCTFail("Expected success, got error: \(error)")
            }
        }

        // Wait a bit for the tokenize to initiate
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        
        // Wait for async operations to complete
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
    }

    func testTokenizeVenmoAccount_vaultFalse_setsVaultToFalse() async {
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()
        
        Task {
            do {
                let _ = try await venmoClient.tokenize(venmoRequest)
                XCTAssertFalse(venmoClient.shouldVault)
            } catch {
                XCTFail("Expected success, got error: \(error)")
            }
        }
        
        // Wait a bit for the tokenize to initiate
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        
        // Wait for async operations to complete
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
    }
    
    func testTokenizeVenmoAccount_vaultTrue_returnsNonce() async {
        mockAPIClient.authorization = try! BTClientToken(clientToken: TestClientTokenFactory.validClientToken)

        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()

        venmoRequest.vault = true

        Task {
            do {
                let venmoAccount = try await venmoClient.tokenize(venmoRequest)
                XCTAssertEqual(venmoAccount.username, "venmojoe")
                XCTAssertEqual(venmoAccount.nonce, "abcd-venmo-nonce")
                XCTAssertTrue(venmoAccount.isDefault)
            } catch {
                XCTFail("Expected success, got error: \(error)")
            }
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

        // Wait a bit for the tokenize to initiate
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        
        // Wait for async operations to complete
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
    }
    
    func testTokenizeVenmoAccount_vaultTrue_sendsSucessAnalyticsEvent() async {
        mockAPIClient.authorization = try! BTClientToken(clientToken: TestClientTokenFactory.validClientToken)

        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()

        venmoRequest.vault = true

        Task {
            do {
                let venmoAccount = try await venmoClient.tokenize(venmoRequest)
                XCTAssertEqual(venmoAccount.username, "venmojoe")
                XCTAssertEqual(venmoAccount.nonce, "abcd-venmo-nonce")
                XCTAssertTrue(venmoAccount.isDefault)
            } catch {
                XCTFail("Expected success, got error: \(error)")
            }
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

        // Wait a bit for the tokenize to initiate
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        
        // Wait for async operations to complete
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, BTVenmoAnalytics.tokenizeSucceeded)
        XCTAssertEqual(mockAPIClient.postedContextID, "some-resource-id")
    }

    func testTokenizeVenmoAccount_vaultTrue_sendsFailureAnalyticsEvent() async {
        mockAPIClient.authorization = try! BTClientToken(clientToken: TestClientTokenFactory.validClientToken)
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()

        venmoRequest.vault = true

        Task {
            do {
                let _ = try await venmoClient.tokenize(venmoRequest)
                XCTFail("Expected error to be thrown")
            } catch {
                XCTAssertNotNil(error)
            }
        }

        mockAPIClient.cannedResponseError = NSError(domain: "Fake Error", code: 400, userInfo: nil)

        // Wait a bit for the tokenize to initiate
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=fake-nonce&username=fake-username")!)
        
        // Wait for async operations to complete
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, BTVenmoAnalytics.tokenizeFailed)
        XCTAssertEqual(mockAPIClient.postedContextID, "some-resource-id")
    }

    func testTokenizeVenmoAccount_whenAppSwitchCanceled_throwsCancelError() async {
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()

        Task {
            do {
                let _ = try await venmoClient.tokenize(venmoRequest)
                XCTFail("Expected error to be thrown")
            } catch {
                let error = error as NSError
                XCTAssertEqual(error.localizedDescription, BTVenmoError.canceled.localizedDescription)
                XCTAssertEqual(error.code, 9)
            }
        }
        
        // Wait a bit for the tokenize to initiate
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/cancel")!)
        
        // Wait for async operations to complete
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
    }

    func testAuthorizeAccountWithProfileID_withNilProfileID_usesDefaultProfileIDAndAccessTokenFromConfiguration() async {
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        let _ = try? await venmoClient.tokenize(venmoRequest)

        XCTAssertTrue(fakeApplication.openURLWasCalled)
        XCTAssertEqual(fakeApplication.lastOpenURL!.scheme, "https")
        XCTAssertNotNil(fakeApplication.lastOpenURL!.absoluteString.range(of: "venmo_merchant_id"));
        XCTAssertNotNil(fakeApplication.lastOpenURL!.absoluteString.range(of: "venmo-access-token"));
    }

    func testAuthorizeAccountWithProfileID_withProfileID_usesProfileIDToAppSwitch() async {
        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoRequest.profileID = "second_venmo_merchant_id"

        let _ = try? await venmoClient.tokenize(venmoRequest)

        XCTAssertTrue(fakeApplication.openURLWasCalled)
        XCTAssertEqual(fakeApplication.lastOpenURL!.scheme, "https")
        XCTAssertNotNil(fakeApplication.lastOpenURL!.absoluteString.range(of: "second_venmo_merchant_id"));
        XCTAssertNotNil(fakeApplication.lastOpenURL!.absoluteString.range(of: "venmo-access-token"));
    }

    func testTokenizeVenmoAccount_whenIsFinalAmountSetAsTrue_createsPaymentContext() async {
        venmoRequest.displayName = "app-display-name"

        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoRequest.isFinalAmount = true
        let _ = try? await venmoClient.tokenize(venmoRequest)

        XCTAssertEqual(mockAPIClient.lastPOSTAPIClientHTTPType, .graphQLAPI)
        let params = mockAPIClient.lastPOSTParameters as? NSDictionary
        if let inputDict = params?["variables"] as? NSDictionary,
           let input = inputDict["input"] as? [String:Any] {
            XCTAssertEqual("true", input["isFinalAmount"] as? String)
        }
    }

    func testTokenizeVenmoAccount_whenIsFinalAmountSetAsFalse_createsPaymentContext() async {
        venmoRequest.displayName = "app-display-name"

        let fakeApplication = FakeApplication()
        venmoClient.application = fakeApplication
        venmoClient.bundle = FakeBundle()

        venmoRequest.isFinalAmount = false
        let _ = try? await venmoClient.tokenize(venmoRequest)

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

    func testTokenize_whenConfigurationIsInvalid_throwsError() async {
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()

        mockAPIClient.cannedConfigurationResponseBody = nil

        do {
            let _ = try await venmoClient.tokenize(venmoRequest)
            XCTFail("Expected error to be thrown")
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

    func testAuthorizeAccountWithTokenizationKey_vaultTrue_willNotAttemptToVault() async {
        venmoClient.application = FakeApplication()
        venmoClient.bundle = FakeBundle()

        let venmoRequest = BTVenmoRequest(paymentMethodUsage: .multiUse)
        venmoRequest.vault = true

        Task {
            do {
                let venmoAccount = try await venmoClient.tokenize(venmoRequest)
                XCTAssertEqual(venmoAccount.username, "venmotim")
                XCTAssertEqual(venmoAccount.nonce, "lmnop-venmo-nonce")
                XCTAssertFalse(venmoAccount.isDefault)
            } catch {
                XCTFail("Expected success, got error: \(error)")
            }
        }

        // Wait a bit for the tokenize to initiate
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        BTVenmoClient.handleReturnURL(URL(string: "scheme://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=lmnop-venmo-nonce&username=venmotim")!)
        
        // Wait for async operations to complete
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

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
