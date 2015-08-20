import XCTest
import BraintreePayPal

// MARK: Authorization

class BTPayPalDriver_Authorization_Tests: XCTestCase {

    var mockAPIClient : MockAPIClient = MockAPIClient(clientKey: "development_client_key")!
    var observers : [NSObjectProtocol] = []

    override func setUp() {
        super.setUp()

        mockAPIClient = MockAPIClient(clientKey: "development_client_key")!
        StubPayPalOneTouchCore.cannedIsWalletAppAvailable = true
    }

    override func tearDown() {
        observers.map { NSNotificationCenter.defaultCenter().removeObserver($0) }
        super.tearDown()
    }

    func testAuthorization_whenRemoteConfigurationFetchFails_callsBackWithConfigurationError() {
        mockAPIClient.cannedConfigurationResponseError = NSError(domain: "", code: 0, userInfo: nil)
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient

        let expectation = self.expectationWithDescription("Checkout fails with error")
        payPalDriver.authorizeAccountWithCompletion { (tokenizedPayPalAccount, error) -> Void in
            XCTAssertEqual(error!, self.mockAPIClient.cannedConfigurationResponseError!)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testAuthorization_whenPayPalConfigurationDisabled_callsBackWithError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [ "paypalEnabled": false ])
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient

        let expectation = expectationWithDescription("authorization callback")
        payPalDriver.authorizeAccountWithCompletion { (tokenizedPayPalAccount, error) -> Void in
            XCTAssertEqual(error!.domain, BTPayPalDriverErrorDomain)
            XCTAssertEqual(error!.code, BTPayPalDriverErrorType.Disabled.rawValue)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testAuthorization_whenRemoteConfigurationIsAvailable_performsAuthorizationAppSwitch() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "paypal": [
                "environment": "offline"
            ] ])
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        payPalDriver.returnURLScheme = "foo://"

        payPalDriver.payPalClass = StubPayPalOneTouchCore.self
        let mockRequestFactory = PayPalMockRequestFactory()
        payPalDriver.requestFactory = mockRequestFactory
        let delegate = MockPaymentDriverDelegate(willPerform: self.expectationWithDescription("Delegate received willPerformAppSwitch"), didPerform:self.expectationWithDescription("Delegate received didPerformAppSwitch"))
        payPalDriver.delegate = delegate

        payPalDriver.authorizeAccountWithCompletion { _ -> Void in }

        waitForExpectationsWithTimeout(2, handler: nil)
        XCTAssertTrue(mockRequestFactory.authorizationRequest.appSwitchPerformed)
    }

    func testAuthorizationRequest_byDefault_containsEmailAndFuturePaymentsScopes() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "paypal": [
                "environment": "offline"
            ] ])
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        payPalDriver.returnURLScheme = "foo://"
        payPalDriver.payPalClass = StubPayPalOneTouchCore.self
        let mockRequestFactory = PayPalMockRequestFactory()
        payPalDriver.requestFactory = mockRequestFactory
        let delegate = MockPaymentDriverDelegate(willPerform: self.expectationWithDescription("Delegate received willPerformAppSwitch"), didPerform:self.expectationWithDescription("Delegate received didPerformAppSwitch"))
        payPalDriver.delegate = delegate

        payPalDriver.authorizeAccountWithCompletion { _ -> Void in }

        waitForExpectationsWithTimeout(5, handler: nil)
        for expectedScope in ["email", "https://uri.paypal.com/services/payments/futurepayments"] {
            XCTAssertTrue(mockRequestFactory.lastScopeValues!.contains(expectedScope))
        }
    }

    func testAuthorizationRequest_whenAdditionalScopesAreSpecified_includesThoseAdditionalScopes() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "paypal": [
                "environment": "offline"
            ] ])
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        payPalDriver.returnURLScheme = "foo://"
        payPalDriver.payPalClass = StubPayPalOneTouchCore.self
        let mockRequestFactory = PayPalMockRequestFactory()
        payPalDriver.requestFactory = mockRequestFactory
        let delegate = MockPaymentDriverDelegate(willPerform: self.expectationWithDescription("Delegate received willPerformAppSwitch"), didPerform:self.expectationWithDescription("Delegate received didPerformAppSwitch"))
        payPalDriver.delegate = delegate

        payPalDriver.authorizeAccountWithAdditionalScopes(Set(["foo", "bar"])) { _ -> Void in }

        waitForExpectationsWithTimeout(5, handler: nil)
        for expectedScope in ["email", "https://uri.paypal.com/services/payments/futurepayments", "foo", "bar"] {
            XCTAssertTrue(mockRequestFactory.lastScopeValues!.contains(expectedScope))
        }
    }

    func testAuthorization_whenAppSwitchCancels_callsBackWithNoResultOrError() {
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        payPalDriver.payPalClass = StubPayPalOneTouchCore.self
        payPalDriver.payPalClass.cannedResult.overrideType = PayPalOneTouchResultType.Cancel

        let expectation = expectationWithDescription("App switch return block invoked")
        payPalDriver.setAuthorizationAppSwitchReturnBlock { (tokenizedAccount, error) -> Void in
            XCTAssertNil(tokenizedAccount)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        BTPayPalDriver.handleAppSwitchReturnURL(NSURL(string: "bar://hello/world")!)

        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testAuthorization_whenAppSwitchSucceeds_tokenizesPayPalAccount() {
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        payPalDriver.payPalClass = StubPayPalOneTouchCore.self
        payPalDriver.payPalClass.cannedResult.overrideType = .Success

        payPalDriver.setAuthorizationAppSwitchReturnBlock { _ -> Void in }
        BTPayPalDriver.handleAppSwitchReturnURL(NSURL(string: "bar://hello/world")!)

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v1/payment_methods/paypal_accounts")
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail("Expected POST to contain parameters");
            return;
        }
        XCTAssertEqual(lastPostParameters["correlation_id"] as? String, StubPayPalOneTouchCore.clientMetadataID())
        let paypalAccount = lastPostParameters["paypal_account"] as! NSDictionary
        XCTAssertEqual(paypalAccount, StubPayPalOneTouchCoreResult().response)
    }

    func testAuthorization_whenAppSwitchSucceeds_makesDelegateCallbacks() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "paypal": [
                "environment": "offline"
            ] ])
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        payPalDriver.returnURLScheme = "foo://"
        let mockRequestFactory = PayPalMockRequestFactory()
        payPalDriver.requestFactory = mockRequestFactory
        let delegate = MockPaymentDriverDelegate(willPerform: expectationWithDescription("willPerformAppSwitch called"), didPerform: expectationWithDescription("didPerformAppSwitch called"))
        delegate.willProcess = expectationWithDescription("willProcessPaymentInfo called")
        payPalDriver.delegate = delegate
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        payPalDriver.payPalClass = StubPayPalOneTouchCore.self
        payPalDriver.payPalClass.cannedResult.overrideType = .Success

        payPalDriver.authorizeAccountWithCompletion { _ -> Void in }
        payPalDriver.setAuthorizationAppSwitchReturnBlock { _ -> Void in }
        BTPayPalDriver.handleAppSwitchReturnURL(NSURL(string: "bar://hello/world")!)

        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testAuthorization_whenAppSwitchWillOccur_postsNotifications() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "paypal": [
                "environment": "offline"
            ] ])
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        payPalDriver.returnURLScheme = "foo://"
        let mockRequestFactory = PayPalMockRequestFactory()
        payPalDriver.requestFactory = mockRequestFactory
        let delegate = MockPaymentDriverDelegate()
        delegate.willPerformAppSwitch = expectationWithDescription("willPerformAppSwitch called")
        payPalDriver.delegate = delegate
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        payPalDriver.payPalClass = StubPayPalOneTouchCore.self
        payPalDriver.payPalClass.cannedResult.overrideType = .Success

        let willAppSwitchNotificationExpectation = expectationWithDescription("willAppSwitch notification received")
        observers.append(NSNotificationCenter.defaultCenter().addObserverForName(BTPaymentDriverWillAppSwitchNotification, object: nil, queue: nil) { (notification) -> Void in
            willAppSwitchNotificationExpectation.fulfill()
        })

        let didAppSwitchNotificationExpectation = expectationWithDescription("didAppSwitch notification received")
        observers.append(NSNotificationCenter.defaultCenter().addObserverForName(BTPaymentDriverDidAppSwitchNotification, object: nil, queue: nil) { (notification) -> Void in
            didAppSwitchNotificationExpectation.fulfill()
        })

        payPalDriver.authorizeAccountWithCompletion { _ -> Void in }

        let willProcessNotificationExpectation = expectationWithDescription("willProcess notification received")
        observers.append(NSNotificationCenter.defaultCenter().addObserverForName(BTPaymentDriverWillProcessPaymentInfoNotification, object: nil, queue: nil) { (notification) -> Void in
            willProcessNotificationExpectation.fulfill()
        })

        payPalDriver.setAuthorizationAppSwitchReturnBlock { _ -> Void in }
        BTPayPalDriver.handleAppSwitchReturnURL(NSURL(string: "bar://hello/world")!)

        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testAuthorization_whenAppSwitchResultIsError_returnsUnderlyingError() {
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        payPalDriver.payPalClass = StubPayPalOneTouchCore.self
        payPalDriver.payPalClass.cannedResult.overrideType = .Error
        let fakeError = NSError(domain: "FakeError", code: 1, userInfo: nil)
        payPalDriver.payPalClass.cannedResult.overrideError = fakeError

        let expectation = self.expectationWithDescription("App switch completion callback")
        payPalDriver.setAuthorizationAppSwitchReturnBlock { (tokenizedAccount, error) -> Void in
            guard let error = error else {
                XCTFail()
                return
            }
            XCTAssertEqual(error, fakeError)
            expectation.fulfill()
        }

        BTPayPalDriver.handleAppSwitchReturnURL(NSURL(string: "bar://hello/world")!)

        waitForExpectationsWithTimeout(5, handler: nil)
    }

    func testTokenizedPayPalAccount_containsPayerInfo() {
        assertSuccessfulAuthorizationResponse([
            "paypalAccounts": [
                [
                    "nonce": "a-nonce",
                    "description": "A description",
                    "details": [
                        "email": "hello@world.com",
                        "payerInfo": [
                            "accountAddress": [
                                "recipientName": "Foo Bar",
                                "street1": "1 Foo Ct",
                                "street2": "Apt Bar",
                                "city": "Fubar",
                                "state": "FU",
                                "postalCode": "42",
                                "country": "USA"
                            ]
                        ]
                    ]
                ] ] ],
            assertionBlock: { (tokenizedPayPalAccount, error) -> Void in
                XCTAssertEqual(tokenizedPayPalAccount!.paymentMethodNonce, "a-nonce")
                XCTAssertEqual(tokenizedPayPalAccount!.localizedDescription, "A description")
                XCTAssertEqual(tokenizedPayPalAccount!.email, "hello@world.com")
                XCTAssertEqual(tokenizedPayPalAccount!.accountAddress!.recipientName!, "Foo Bar")
                XCTAssertEqual(tokenizedPayPalAccount!.accountAddress!.streetAddress, "1 Foo Ct")
                XCTAssertEqual(tokenizedPayPalAccount!.accountAddress!.extendedAddress!, "Apt Bar")
                XCTAssertEqual(tokenizedPayPalAccount!.accountAddress!.locality, "Fubar")
                XCTAssertEqual(tokenizedPayPalAccount!.accountAddress!.region!, "FU")
                XCTAssertEqual(tokenizedPayPalAccount!.accountAddress!.postalCode!, "42")
                XCTAssertEqual(tokenizedPayPalAccount!.accountAddress!.countryCodeAlpha2, "USA")
        })
    }

    func testTokenizedPayPalAccount_whenEmailAddressIsNestedInsidePayerInfoJSON_usesNestedEmailAddress() {
        assertSuccessfulAuthorizationResponse([
            "paypalAccounts": [
                [
                    "details": [
                        "email": "not-hello@world.com",
                        "payerInfo": [
                            "email": "hello@world.com",
                        ]
                    ],
                ]
            ] ],
            assertionBlock: { (tokenizedPayPalCheckout, error) -> Void in
                XCTAssertEqual(tokenizedPayPalCheckout!.email, "hello@world.com")
        })
    }

    func testTokenizedPayPalAccount_whenDescriptionJSONIsPayPal_usesEmailAsLocalizedDescription() {
        assertSuccessfulAuthorizationResponse([
            "paypalAccounts": [
                [
                    "description": "PayPal",
                    "details": [
                        "email": "hello@world.com",
                    ],
                ]
            ] ],
            assertionBlock: { (tokenizedPayPalCheckout, error) -> Void in
                XCTAssertEqual(tokenizedPayPalCheckout!.localizedDescription, "hello@world.com")
        })
    }

    // MARK: Helpers

    func assertSuccessfulAuthorizationResponse(response: [String:AnyObject], assertionBlock: (BTTokenizedPayPalAccount?, NSError?) -> Void) {
        mockAPIClient.cannedResponseBody = BTJSON(value: response);
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        payPalDriver.payPalClass = StubPayPalOneTouchCore.self
        payPalDriver.payPalClass.cannedResult.overrideType = .Success

        payPalDriver.setAuthorizationAppSwitchReturnBlock { (tokenizedPayPalAccount, error) -> Void in
            assertionBlock(tokenizedPayPalAccount, error)
        }
        BTPayPalDriver.handleAppSwitchReturnURL(NSURL(string: "bar://hello/world")!)

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v1/payment_methods/paypal_accounts")
    }
}

// MARK: - Checkout

class BTPayPalDriver_Checkout_Tests: XCTestCase {

    var mockAPIClient : MockAPIClient = MockAPIClient(clientKey: "development_client_key")!

    override func setUp() {
        super.setUp()

        mockAPIClient = MockAPIClient(clientKey: "development_client_key")!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "paypal": [
                "environment": "offline"
            ] ])
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": [
                "redirectURL": "fakeURL://"
            ] ])

    }

    func testCheckout_whenRemoteConfigurationFetchFails_callsBackWithConfigurationError() {
        mockAPIClient.cannedConfigurationResponseBody = nil
        mockAPIClient.cannedConfigurationResponseError = NSError(domain: "", code: 0, userInfo: nil)
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        payPalDriver.payPalClass = StubPayPalOneTouchCore.self

        let request = BTPayPalCheckoutRequest(amount: NSDecimalNumber(string: "1"))!
        let expectation = self.expectationWithDescription("Checkout fails with error")
        payPalDriver.checkoutWithCheckoutRequest(request) { (_, error) -> Void in
            XCTAssertEqual(error!, self.mockAPIClient.cannedConfigurationResponseError!)
            expectation.fulfill()
        }

        self.waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testCheckout_whenRemoteConfigurationFetchSucceeds_postsPaymentResource() {
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        payPalDriver.returnURLScheme = "foo://"
        let checkoutRequest = BTPayPalCheckoutRequest(amount: NSDecimalNumber(string: "1"))!
        checkoutRequest.currencyCode = "GBP"
        payPalDriver.payPalClass = StubPayPalOneTouchCore.self

        payPalDriver.checkoutWithCheckoutRequest(checkoutRequest) { _ -> Void in }

        XCTAssertEqual("v1/paypal_hermes/create_payment_resource", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        XCTAssertEqual(lastPostParameters["amount"] as? String, "1")
        XCTAssertEqual(lastPostParameters["currency_iso_code"] as? String, "GBP")
        XCTAssertEqual(lastPostParameters["return_url"] as? String, "scheme://return")
        XCTAssertEqual(lastPostParameters["cancel_url"] as? String, "scheme://cancel")
        XCTAssertEqual(lastPostParameters["correlation_id"] as? String, StubPayPalOneTouchCore.clientMetadataID())
    }

    func testCheckout_whenPayPalPaymentCreationSuccessful_performsAppSwitch() {
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        payPalDriver.returnURLScheme = "foo://"
        let mockRequestFactory = PayPalMockRequestFactory()
        payPalDriver.requestFactory = mockRequestFactory
        let delegate = MockPaymentDriverDelegate(willPerform: self.expectationWithDescription("Delegate received willPerformAppSwitch"), didPerform: expectationWithDescription("Delegate received didPerformAppSwitch"))
        payPalDriver.delegate = delegate
        payPalDriver.payPalClass = StubPayPalOneTouchCore.self

        let request = BTPayPalCheckoutRequest(amount: NSDecimalNumber(string: "1"))!
        payPalDriver.checkoutWithCheckoutRequest(request) { _ -> Void in }

        self.waitForExpectationsWithTimeout(2, handler: nil)
        XCTAssertTrue(mockRequestFactory.checkoutRequest.appSwitchPerformed)
    }

    func testCheckout_whenPaymentResourceCreationFails_callsBackWithError() {
        mockAPIClient.cannedResponseError = NSError(domain: "", code: 0, userInfo: nil)

        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        payPalDriver.returnURLScheme = "foo://"
        payPalDriver.payPalClass = StubPayPalOneTouchCore.self
        let dummyRequest = BTPayPalCheckoutRequest(amount: NSDecimalNumber(string: "1"))!
        let expectation = self.expectationWithDescription("Checkout fails with error")
        payPalDriver.checkoutWithCheckoutRequest(dummyRequest) { (_, error) -> Void in
            XCTAssertEqual(error!, self.mockAPIClient.cannedResponseError!)
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testCheckout_whenAppSwitchCancels_callsBackWithNoResultOrError() {
        let payPalDriver = BTPayPalDriver(APIClient:mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        payPalDriver.returnURLScheme = "foo://"
        let returnURL = NSURL(string: "bar://hello/world")!

        let continuationExpectation = self.expectationWithDescription("Continuation called")

        payPalDriver.payPalClass = StubPayPalOneTouchCore.self
        payPalDriver.payPalClass.cannedResult.overrideType = .Cancel
        payPalDriver.setCheckoutAppSwitchReturnBlock { (tokenizedCheckout, error) -> Void in
            XCTAssertNil(tokenizedCheckout)
            XCTAssertNil(error)
            continuationExpectation.fulfill()
        }

        BTPayPalDriver.handleAppSwitchReturnURL(returnURL)

        self.waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testCheckout_whenAppSwitchErrors_callsBackWithError() {
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        payPalDriver.returnURLScheme = "foo://"
        let returnURL = NSURL(string: "bar://hello/world")!

        let continuationExpectation = self.expectationWithDescription("Continuation called")

        payPalDriver.payPalClass = StubPayPalOneTouchCore.self
        payPalDriver.payPalClass.cannedResult.overrideType = .Error
        payPalDriver.payPalClass.cannedResult.overrideError = NSError(domain: "", code: 0, userInfo: nil)

        payPalDriver.setCheckoutAppSwitchReturnBlock { (tokenizedCheckout, error) -> Void in
            XCTAssertNil(tokenizedCheckout)
            XCTAssertEqual(error!, payPalDriver.payPalClass.cannedResult.error!)
            continuationExpectation.fulfill()
        }

        BTPayPalDriver.handleAppSwitchReturnURL(returnURL)

        self.waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testCheckout_whenAppSwitchSucceeds_tokenizesPayPalCheckout() {
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        payPalDriver.payPalClass = StubPayPalOneTouchCore.self
        payPalDriver.payPalClass.cannedResult.overrideType = .Success

        payPalDriver.setCheckoutAppSwitchReturnBlock { _ -> Void in }
        BTPayPalDriver.handleAppSwitchReturnURL(NSURL(string: "bar://hello/world")!)

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v1/payment_methods/paypal_accounts")
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        let paypalAccount = lastPostParameters["paypal_account"] as! NSDictionary
        let options = paypalAccount["options"] as! NSDictionary
        let validate = (options["validate"] as! NSNumber).boolValue
        XCTAssertFalse(validate)
    }

    func testCheckout_whenAppSwitchSucceeds_makesDelegateCallback() {
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        let delegate = MockPaymentDriverDelegate()
        delegate.willProcess = expectationWithDescription("willProcessPaymentInfo called")
        payPalDriver.delegate = delegate
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        payPalDriver.payPalClass = StubPayPalOneTouchCore.self
        payPalDriver.payPalClass.cannedResult.overrideType = .Success

        payPalDriver.setCheckoutAppSwitchReturnBlock { _ -> Void in }
        BTPayPalDriver.handleAppSwitchReturnURL(NSURL(string: "bar://hello/world")!)

        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testCheckout_whenAppSwitchResultIsError_returnsUnderlyingError() {
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        payPalDriver.payPalClass = StubPayPalOneTouchCore.self
        payPalDriver.payPalClass.cannedResult.overrideType = .Error
        let fakeError = NSError(domain: "FakeError", code: 1, userInfo: nil)
        payPalDriver.payPalClass.cannedResult.overrideError = fakeError

        let expectation = self.expectationWithDescription("App switch completion callback")
        payPalDriver.setCheckoutAppSwitchReturnBlock { (tokenizedCheckout, error) -> Void in
            guard let error = error else {
                XCTFail()
                return
            }
            XCTAssertEqual(error, fakeError)
            expectation.fulfill()
        }

        BTPayPalDriver.handleAppSwitchReturnURL(NSURL(string: "bar://hello/world")!)

        self.waitForExpectationsWithTimeout(5, handler: nil)
    }

    func testTokenizedPayPalCheckout_containsPayerInfo() {
        assertSuccessfulCheckoutResponse([
            "paypalAccounts": [
                [
                    "nonce": "a-nonce",
                    "description": "A description",
                    "details": [
                        "email": "hello@world.com",
                        "payerInfo": [
                            "firstName": "Some",
                            "lastName": "Dude",
                            "phone": "867-5309",
                            "accountAddress": [
                                "street1": "1 Foo Ct",
                                "street2": "Apt Bar",
                                "city": "Fubar",
                                "state": "FU",
                                "postalCode": "42",
                                "country": "USA"
                            ],
                            "billingAddress": [
                                "recipientName": "Bar Foo",
                                "line1": "2 Foo Ct",
                                "line2": "Apt Foo",
                                "city": "Barfoo",
                                "state": "BF",
                                "postalCode": "24",
                                "countryCode": "ASU"
                            ],
                            "shippingAddress": [
                                "recipientName": "Some Dude",
                                "line1": "3 Foo Ct",
                                "line2": "Apt 5",
                                "city": "Dudeville",
                                "state": "CA",
                                "postalCode": "24",
                                "countryCode": "US"
                            ]
                        ]
                    ]
                ] ] ],
            assertionBlock: { (tokenizedPayPalCheckout, error) -> Void in
                XCTAssertEqual(tokenizedPayPalCheckout!.paymentMethodNonce, "a-nonce")
                XCTAssertEqual(tokenizedPayPalCheckout!.localizedDescription, "A description")
                XCTAssertEqual(tokenizedPayPalCheckout!.firstName, "Some")
                XCTAssertEqual(tokenizedPayPalCheckout!.lastName, "Dude")
                XCTAssertEqual(tokenizedPayPalCheckout!.phone, "867-5309")
                XCTAssertEqual(tokenizedPayPalCheckout!.email, "hello@world.com")
                XCTAssertEqual(tokenizedPayPalCheckout!.billingAddress.recipientName!, "Bar Foo")
                XCTAssertEqual(tokenizedPayPalCheckout!.billingAddress.streetAddress, "2 Foo Ct")
                XCTAssertEqual(tokenizedPayPalCheckout!.billingAddress.extendedAddress!, "Apt Foo")
                XCTAssertEqual(tokenizedPayPalCheckout!.billingAddress.locality, "Barfoo")
                XCTAssertEqual(tokenizedPayPalCheckout!.billingAddress.region!, "BF")
                XCTAssertEqual(tokenizedPayPalCheckout!.billingAddress.postalCode!, "24")
                XCTAssertEqual(tokenizedPayPalCheckout!.billingAddress.countryCodeAlpha2, "ASU")
                XCTAssertEqual(tokenizedPayPalCheckout!.shippingAddress.recipientName!, "Some Dude")
                XCTAssertEqual(tokenizedPayPalCheckout!.shippingAddress.streetAddress, "3 Foo Ct")
                XCTAssertEqual(tokenizedPayPalCheckout!.shippingAddress.extendedAddress!, "Apt 5")
                XCTAssertEqual(tokenizedPayPalCheckout!.shippingAddress.locality, "Dudeville")
                XCTAssertEqual(tokenizedPayPalCheckout!.shippingAddress.region!, "CA")
                XCTAssertEqual(tokenizedPayPalCheckout!.shippingAddress.postalCode!, "24")
                XCTAssertEqual(tokenizedPayPalCheckout!.shippingAddress.countryCodeAlpha2, "US")
        })
    }

    func testTokenizedPayPalCheckout_whenEmailAddressIsNestedInsidePayerInfoJSON_usesNestedEmailAddress() {
        assertSuccessfulCheckoutResponse([
            "paypalAccounts": [
                [
                    "details": [
                        "email": "not-hello@world.com",
                        "payerInfo": [
                            "email": "hello@world.com",
                        ]
                    ],
                ]
            ] ],
            assertionBlock: { (tokenizedPayPalCheckout, error) -> Void in
                XCTAssertEqual(tokenizedPayPalCheckout!.email, "hello@world.com")
        })
    }

    func testTokenizedPayPalCheckout_whenDescriptionJSONIsPayPal_usesEmailAsLocalizedDescription() {
        assertSuccessfulCheckoutResponse([
            "paypalAccounts": [
                [
                    "description": "PayPal",
                    "details": [
                        "email": "hello@world.com",
                    ],
                ]
            ] ],
            assertionBlock: { (tokenizedPayPalCheckout, error) -> Void in
                XCTAssertEqual(tokenizedPayPalCheckout!.localizedDescription, "hello@world.com")
        })
    }

    func testMetadata_whenCheckoutAppSwitchIsSuccessful_isPOSTedToServer() {
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        let stubPayPalClass = StubPayPalOneTouchCore.self
        stubPayPalClass.cannedResult.overrideType = .Success
        payPalDriver.payPalClass = stubPayPalClass
        payPalDriver.setCheckoutAppSwitchReturnBlock { _ -> Void in }
        BTPayPalDriver.handleAppSwitchReturnURL(NSURL(string: "bar://hello/world")!)

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v1/payment_methods/paypal_accounts")
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        let metaParameters = lastPostParameters["_meta"] as! NSDictionary
        XCTAssertEqual(metaParameters["source"] as? String, "paypal-app")
        XCTAssertEqual(metaParameters["integration"] as? String, mockAPIClient.metadata.integrationString)
    }

    func testMetadata_whenCheckoutBrowserSwitchIsSuccessful_isPOSTedToServer() {
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        let stubPayPalClass = StubPayPalOneTouchCore.self
        stubPayPalClass.cannedResult.overrideType = .Success
        stubPayPalClass.cannedIsWalletAppAvailable = false
        payPalDriver.payPalClass = stubPayPalClass
        payPalDriver.setCheckoutAppSwitchReturnBlock { _ -> Void in }
        BTPayPalDriver.handleAppSwitchReturnURL(NSURL(string: "bar://hello/world")!)

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v1/payment_methods/paypal_accounts")
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        let metaParameters = lastPostParameters["_meta"] as! NSDictionary
        XCTAssertEqual(metaParameters["source"] as? String, "paypal-browser")
        XCTAssertEqual(metaParameters["integration"] as? String, mockAPIClient.metadata.integrationString)
    }

    // MARK: Helpers

    func assertSuccessfulCheckoutResponse(response: [String:AnyObject], assertionBlock: (BTTokenizedPayPalCheckout?, NSError?) -> Void) {
        mockAPIClient.cannedResponseBody = BTJSON(value: response);
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        payPalDriver.payPalClass = StubPayPalOneTouchCore.self
        payPalDriver.payPalClass.cannedResult.overrideType = .Success

        payPalDriver.setCheckoutAppSwitchReturnBlock { (tokenizedPayPalCheckout, error) -> Void in
            assertionBlock(tokenizedPayPalCheckout, error)
        }
        BTPayPalDriver.handleAppSwitchReturnURL(NSURL(string: "bar://hello/world")!)
    }
}


// MARK: - Test Doubles

class StubPayPalOneTouchCoreResult : PayPalOneTouchCoreResult {
    var overrideError : NSError?
    override var error : NSError? {
        get {
            return overrideError
        }
    }

    var overrideType: PayPalOneTouchResultType
    override var type : PayPalOneTouchResultType {
        get {
            return overrideType
        }
    }

    var overrideTarget: PayPalOneTouchRequestTarget
    override var target : PayPalOneTouchRequestTarget {
        get {
            return overrideTarget
        }
    }

    override init() {
        overrideError = nil
        overrideType = .Success
        overrideTarget = .Unknown
    }

    override var response : [NSObject : AnyObject] {
        get {
            return ["foo": "bar"]
        }
    }
}

class StubPayPalOneTouchCore : PayPalOneTouchCore {

    static var cannedResult = StubPayPalOneTouchCoreResult()
    static var cannedIsWalletAppAvailable = true

    override class func parseResponseURL(url: NSURL!, completionBlock: PayPalOneTouchCompletionBlock!) {
        completionBlock(self.cannedResult)
    }

    override class func redirectURLsForCallbackURLScheme(callbackURLScheme: String!,
        withReturnURL returnURL: AutoreleasingUnsafeMutablePointer<NSString?>,
        withCancelURL cancelURL: AutoreleasingUnsafeMutablePointer<NSString?>) {
            cancelURL.memory = "scheme://cancel"
            returnURL.memory = "scheme://return"
    }

    override class func clientMetadataID() -> String! {
        return "mock-client-metadata-id"
    }

    override class func doesApplicationSupportOneTouchCallbackURLScheme(callbackURLScheme: String!) -> Bool {
        return true
    }

    override class func isWalletAppInstalled() -> Bool {
        return cannedIsWalletAppAvailable
    }
}

class MockPayPalCheckoutRequest : PayPalOneTouchCheckoutRequest {
    var cannedSuccess : Bool
    var cannedTarget : PayPalOneTouchRequestTarget
    var cannedError : NSError?
    var cannedMetadataId : String
    var appSwitchPerformed = false

    override init() {
        cannedError = nil
        cannedTarget = .Browser
        cannedSuccess = true
        cannedMetadataId = ""
    }

    override func performWithCompletionBlock(completionBlock: PayPalOneTouchRequestCompletionBlock!) {
        appSwitchPerformed = true
        completionBlock(ObjCBool(cannedSuccess), cannedTarget, cannedMetadataId, cannedError)
    }
}

class MockPayPalAuthorizationRequest : PayPalOneTouchAuthorizationRequest {
    var cannedSuccess : Bool
    var cannedTarget : PayPalOneTouchRequestTarget
    var cannedError : NSError?
    var cannedMetadataId : String
    var appSwitchPerformed = false

    override init() {
        cannedError = nil
        cannedTarget = .Browser
        cannedSuccess = true
        cannedMetadataId = ""
    }

    override func performWithCompletionBlock(completionBlock: PayPalOneTouchRequestCompletionBlock!) {
        appSwitchPerformed = true
        completionBlock(ObjCBool(cannedSuccess), cannedTarget, cannedMetadataId, cannedError)
    }
}

class PayPalMockRequestFactory : BTPayPalRequestFactory {
    var checkoutRequest = MockPayPalCheckoutRequest()
    var authorizationRequest = MockPayPalAuthorizationRequest()
    var lastScopeValues : Set<NSObject>? = nil

    override func requestWithApprovalURL(approvalURL: NSURL!, clientID: String!, environment: String!, callbackURLScheme: String!) -> PayPalOneTouchCheckoutRequest! {
        return checkoutRequest
    }

    override func requestWithScopeValues(scopeValues: Set<NSObject>!, privacyURL: NSURL!, agreementURL: NSURL!, clientID: String!, environment: String!, callbackURLScheme: String!) -> PayPalOneTouchAuthorizationRequest {
        lastScopeValues = scopeValues
        return authorizationRequest
    }
}
