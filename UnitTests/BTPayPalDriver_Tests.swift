import XCTest

// MARK: Authorization

class BTPayPalDriver_Authorization_Tests: XCTestCase {

    var mockAPIClient : MockAPIClient = MockAPIClient(clientKey: "development_client_key")!
    var observers : [NSObjectProtocol] = []
    let ValidClientToken = "eyJ2ZXJzaW9uIjoyLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiI3ODJhZmFlNDJlZTNiNTA4NWUxNmMzYjhkZTY3OGQxNTJhODFlYzk5MTBmZDNhY2YyYWU4MzA2OGI4NzE4YWZhfGNyZWF0ZWRfYXQ9MjAxNS0wOC0yMFQwMjoxMTo1Ni4yMTY1NDEwNjErMDAwMFx1MDAyNmN1c3RvbWVyX2lkPTM3OTU5QTE5LThCMjktNDVBNC1CNTA3LTRFQUNBM0VBOEM4Nlx1MDAyNm1lcmNoYW50X2lkPWRjcHNweTJicndkanIzcW5cdTAwMjZwdWJsaWNfa2V5PTl3d3J6cWszdnIzdDRuYzgiLCJjb25maWdVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvZGNwc3B5MmJyd2RqcjNxbi9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24iLCJjaGFsbGVuZ2VzIjpbXSwiZW52aXJvbm1lbnQiOiJzYW5kYm94IiwiY2xpZW50QXBpVXJsIjoiaHR0cHM6Ly9hcGkuc2FuZGJveC5icmFpbnRyZWVnYXRld2F5LmNvbTo0NDMvbWVyY2hhbnRzL2RjcHNweTJicndkanIzcW4vY2xpZW50X2FwaSIsImFzc2V0c1VybCI6Imh0dHBzOi8vYXNzZXRzLmJyYWludHJlZWdhdGV3YXkuY29tIiwiYXV0aFVybCI6Imh0dHBzOi8vYXV0aC52ZW5tby5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwiYW5hbHl0aWNzIjp7InVybCI6Imh0dHBzOi8vY2xpZW50LWFuYWx5dGljcy5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIn0sInRocmVlRFNlY3VyZUVuYWJsZWQiOnRydWUsInRocmVlRFNlY3VyZSI6eyJsb29rdXBVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvZGNwc3B5MmJyd2RqcjNxbi90aHJlZV9kX3NlY3VyZS9sb29rdXAifSwicGF5cGFsRW5hYmxlZCI6dHJ1ZSwicGF5cGFsIjp7ImRpc3BsYXlOYW1lIjoiQWNtZSBXaWRnZXRzLCBMdGQuIChTYW5kYm94KSIsImNsaWVudElkIjpudWxsLCJwcml2YWN5VXJsIjoiaHR0cDovL2V4YW1wbGUuY29tL3BwIiwidXNlckFncmVlbWVudFVybCI6Imh0dHA6Ly9leGFtcGxlLmNvbS90b3MiLCJiYXNlVXJsIjoiaHR0cHM6Ly9hc3NldHMuYnJhaW50cmVlZ2F0ZXdheS5jb20iLCJhc3NldHNVcmwiOiJodHRwczovL2NoZWNrb3V0LnBheXBhbC5jb20iLCJkaXJlY3RCYXNlVXJsIjpudWxsLCJhbGxvd0h0dHAiOnRydWUsImVudmlyb25tZW50Tm9OZXR3b3JrIjp0cnVlLCJlbnZpcm9ubWVudCI6Im9mZmxpbmUiLCJ1bnZldHRlZE1lcmNoYW50IjpmYWxzZSwiYnJhaW50cmVlQ2xpZW50SWQiOiJtYXN0ZXJjbGllbnQzIiwiYmlsbGluZ0FncmVlbWVudHNFbmFibGVkIjpmYWxzZSwibWVyY2hhbnRBY2NvdW50SWQiOiJzdGNoMm5mZGZ3c3p5dHc1IiwiY3VycmVuY3lJc29Db2RlIjoiVVNEIn0sImNvaW5iYXNlRW5hYmxlZCI6dHJ1ZSwiY29pbmJhc2UiOnsiY2xpZW50SWQiOiIxMWQyNzIyOWJhNThiNTZkN2UzYzAxYTA1MjdmNGQ1YjQ0NmQ0ZjY4NDgxN2NiNjIzZDI1NWI1NzNhZGRjNTliIiwibWVyY2hhbnRBY2NvdW50IjoiY29pbmJhc2UtZGV2ZWxvcG1lbnQtbWVyY2hhbnRAZ2V0YnJhaW50cmVlLmNvbSIsInNjb3BlcyI6ImF1dGhvcml6YXRpb25zOmJyYWludHJlZSB1c2VyIiwicmVkaXJlY3RVcmwiOiJodHRwczovL2Fzc2V0cy5icmFpbnRyZWVnYXRld2F5LmNvbS9jb2luYmFzZS9vYXV0aC9yZWRpcmVjdC1sYW5kaW5nLmh0bWwiLCJlbnZpcm9ubWVudCI6Im1vY2sifSwibWVyY2hhbnRJZCI6ImRjcHNweTJicndkanIzcW4iLCJ2ZW5tbyI6Im9mZmxpbmUiLCJhcHBsZVBheSI6eyJzdGF0dXMiOiJtb2NrIiwiY291bnRyeUNvZGUiOiJVUyIsImN1cnJlbmN5Q29kZSI6IlVTRCIsIm1lcmNoYW50SWRlbnRpZmllciI6Im1lcmNoYW50LmNvbS5icmFpbnRyZWVwYXltZW50cy5zYW5kYm94LkJyYWludHJlZS1EZW1vIiwic3VwcG9ydGVkTmV0d29ya3MiOlsidmlzYSIsIm1hc3RlcmNhcmQiLCJhbWV4Il19fQ=="


    override func setUp() {
        super.setUp()

        mockAPIClient = MockAPIClient(clientKey: "development_client_key")!
        FakePayPalOneTouchCore.setCannedIsWalletAppAvailable(true)
    }

    override func tearDown() {
        for observer in observers { NSNotificationCenter.defaultCenter().removeObserver(observer) }
        super.tearDown()
    }
    
    func testAuthorization_whenAPIClientIsNil_callsBackWithError() {
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        payPalDriver.apiClient = nil
        
        let expectation = self.expectationWithDescription("Authorization fails with error")
        payPalDriver.authorizeAccountWithCompletion { (tokenizedPayPalAccount, error) -> Void in
            XCTAssertNil(tokenizedPayPalAccount)
            XCTAssertEqual(error!.domain, BTPayPalDriverErrorDomain)
            XCTAssertEqual(error!.code, BTPayPalDriverErrorType.Integration.rawValue)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testAuthorization_whenRemoteConfigurationFetchFails_callsBackWithConfigurationError() {
        mockAPIClient.cannedConfigurationResponseError = NSError(domain: "", code: 0, userInfo: nil)
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient

        let expectation = self.expectationWithDescription("Authorization fails with error")
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

        BTPayPalDriver.setPayPalClass(FakePayPalOneTouchCore.self)
        let mockRequestFactory = FakePayPalRequestFactory()
        payPalDriver.requestFactory = mockRequestFactory
        let delegate = MockAppSwitchDelegate(willPerform: self.expectationWithDescription("Delegate received willPerformAppSwitch"), didPerform:self.expectationWithDescription("Delegate received didPerformAppSwitch"))
        payPalDriver.delegate = delegate

        payPalDriver.authorizeAccountWithCompletion { _ -> Void in }

        waitForExpectationsWithTimeout(2, handler: nil)
        XCTAssertTrue(mockRequestFactory.authorizationRequest.appSwitchPerformed)
    }
    
    func testAuthorization_whenBillingAgreementsEnabledInConfiguration_performsBillingAgreements() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "paypal": [
                "environment": "offline",
                "billingAgreementsEnabled": true,
                "currencyIsoCode": "GBP",
            ] ])

        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        payPalDriver.returnURLScheme = "foo://"
        BTPayPalDriver.setPayPalClass(FakePayPalOneTouchCore.self)

        payPalDriver.authorizeAccountWithCompletion { _ -> Void in
        }
        
        XCTAssertEqual("v1/paypal_hermes/setup_billing_agreement", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        // We want to make sure that currency is not used for Billing Agreements
        XCTAssertTrue(lastPostParameters["currency_iso_code"] == nil)
        XCTAssertEqual(lastPostParameters["return_url"] as? String, "scheme://return")
        XCTAssertEqual(lastPostParameters["cancel_url"] as? String, "scheme://cancel")
    }

    func testAuthorizationRequest_byDefault_containsEmailAndFuturePaymentsScopes() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "paypal": [
                "environment": "offline"
            ] ])
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        payPalDriver.returnURLScheme = "foo://"
        BTPayPalDriver.setPayPalClass(FakePayPalOneTouchCore.self)
        let mockRequestFactory = FakePayPalRequestFactory()
        payPalDriver.requestFactory = mockRequestFactory
        let delegate = MockAppSwitchDelegate(willPerform: self.expectationWithDescription("Delegate received willPerformAppSwitch"), didPerform:self.expectationWithDescription("Delegate received didPerformAppSwitch"))
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
        BTPayPalDriver.setPayPalClass(FakePayPalOneTouchCore.self)
        let mockRequestFactory = FakePayPalRequestFactory()
        payPalDriver.requestFactory = mockRequestFactory
        let delegate = MockAppSwitchDelegate(willPerform: self.expectationWithDescription("Delegate received willPerformAppSwitch"), didPerform:self.expectationWithDescription("Delegate received didPerformAppSwitch"))
        payPalDriver.delegate = delegate

        payPalDriver.authorizeAccountWithAdditionalScopes(Set(["foo", "bar"])) { _ -> Void in }

        waitForExpectationsWithTimeout(5, handler: nil)
        for expectedScope in ["email", "https://uri.paypal.com/services/payments/futurepayments", "foo", "bar"] {
            XCTAssertTrue(mockRequestFactory.lastScopeValues!.contains(expectedScope))
        }
    }
    
    func testAuthorizationRequest_whenUsingClientKey_includesClientKeyInAdditionalPayloadAttributes() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "paypal": [
                "environment": "offline"
            ] ])
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        payPalDriver.returnURLScheme = "foo://"
        BTPayPalDriver.setPayPalClass(FakePayPalOneTouchCore.self)
        let mockRequestFactory = FakePayPalRequestFactory()
        payPalDriver.requestFactory = mockRequestFactory
        let mockRequest = mockRequestFactory.authorizationRequest
        let delegate = MockAppSwitchDelegate(willPerform: self.expectationWithDescription("Delegate received willPerformAppSwitch"), didPerform:self.expectationWithDescription("Delegate received didPerformAppSwitch"))
        payPalDriver.delegate = delegate
        
        payPalDriver.authorizeAccountWithCompletion { _ -> Void in }
        
        waitForExpectationsWithTimeout(5, handler: nil)
        XCTAssertEqual(mockRequest.additionalPayloadAttributes["client_key"] as? String, "development_client_key")
    }
    
    func testAuthorizationRequest_whenUsingClientToken_includesClientTokenInAdditionalPayloadAttributes() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "paypal": [
                "environment": "offline"
            ] ])
        mockAPIClient.clientKey = nil
        mockAPIClient.clientToken = try! BTClientToken(clientToken: ValidClientToken)
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        payPalDriver.returnURLScheme = "foo://"
        BTPayPalDriver.setPayPalClass(FakePayPalOneTouchCore.self)
        let mockRequestFactory = FakePayPalRequestFactory()
        payPalDriver.requestFactory = mockRequestFactory
        let mockRequest = mockRequestFactory.authorizationRequest
        let delegate = MockAppSwitchDelegate(willPerform: self.expectationWithDescription("Delegate received willPerformAppSwitch"), didPerform:self.expectationWithDescription("Delegate received didPerformAppSwitch"))
        payPalDriver.delegate = delegate
        
        payPalDriver.authorizeAccountWithCompletion { _ -> Void in }
        
        waitForExpectationsWithTimeout(5, handler: nil)
        XCTAssertEqual(mockRequest.additionalPayloadAttributes["client_token"] as? String, ValidClientToken)
    }


    func testAuthorization_whenAppSwitchCancels_callsBackWithNoResultOrError() {
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        BTPayPalDriver.setPayPalClass(FakePayPalOneTouchCore.self)
        BTPayPalDriver.payPalClass().cannedResult()?.cannedType = PayPalOneTouchResultType.Cancel

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
        payPalDriver.clientMetadataId = FakePayPalOneTouchCore.clientMetadataID()
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        BTPayPalDriver.setPayPalClass(FakePayPalOneTouchCore.self)
        BTPayPalDriver.payPalClass().cannedResult()?.cannedType = PayPalOneTouchResultType.Success

        payPalDriver.setAuthorizationAppSwitchReturnBlock { _ -> Void in }
        BTPayPalDriver.handleAppSwitchReturnURL(NSURL(string: "bar://hello/world")!)

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v1/payment_methods/paypal_accounts")
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail("Expected POST to contain parameters")
            return
        }
        XCTAssertEqual(lastPostParameters["correlation_id"] as? String, FakePayPalOneTouchCore.clientMetadataID())
        let paypalAccount = lastPostParameters["paypal_account"] as! NSDictionary
        XCTAssertEqual(paypalAccount, FakePayPalOneTouchCoreResult().response)
    }

    func testAuthorization_whenAppSwitchSucceeds_makesDelegateCallbacks() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "paypal": [
                "environment": "offline"
            ] ])
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        payPalDriver.returnURLScheme = "foo://"
        let mockRequestFactory = FakePayPalRequestFactory()
        payPalDriver.requestFactory = mockRequestFactory
        let delegate = MockAppSwitchDelegate(willPerform: expectationWithDescription("willPerformAppSwitch called"), didPerform: expectationWithDescription("didPerformAppSwitch called"))
        delegate.willProcess = expectationWithDescription("willProcessPaymentInfo called")
        payPalDriver.delegate = delegate
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        BTPayPalDriver.setPayPalClass(FakePayPalOneTouchCore.self)
        BTPayPalDriver.payPalClass().cannedResult()?.cannedType = PayPalOneTouchResultType.Success

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
        let mockRequestFactory = FakePayPalRequestFactory()
        payPalDriver.requestFactory = mockRequestFactory
        let delegate = MockAppSwitchDelegate()
        delegate.willPerformAppSwitch = expectationWithDescription("willPerformAppSwitch called")
        payPalDriver.delegate = delegate
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        BTPayPalDriver.setPayPalClass(FakePayPalOneTouchCore.self)
        BTPayPalDriver.payPalClass().cannedResult()?.cannedType = PayPalOneTouchResultType.Success

        let willAppSwitchNotificationExpectation = expectationWithDescription("willAppSwitch notification received")
        observers.append(NSNotificationCenter.defaultCenter().addObserverForName(BTAppSwitchWillSwitchNotification, object: nil, queue: nil) { (notification) -> Void in
            willAppSwitchNotificationExpectation.fulfill()
        })

        let didAppSwitchNotificationExpectation = expectationWithDescription("didAppSwitch notification received")
        observers.append(NSNotificationCenter.defaultCenter().addObserverForName(BTAppSwitchDidSwitchNotification, object: nil, queue: nil) { (notification) -> Void in
            didAppSwitchNotificationExpectation.fulfill()
        })

        payPalDriver.authorizeAccountWithCompletion { _ -> Void in }

        let willProcessNotificationExpectation = expectationWithDescription("willProcess notification received")
        observers.append(NSNotificationCenter.defaultCenter().addObserverForName(BTAppSwitchWillProcessPaymentInfoNotification, object: nil, queue: nil) { (notification) -> Void in
            willProcessNotificationExpectation.fulfill()
        })

        payPalDriver.setAuthorizationAppSwitchReturnBlock { _ -> Void in }
        BTPayPalDriver.handleAppSwitchReturnURL(NSURL(string: "bar://hello/world")!)

        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testAuthorization_whenAppSwitchResultIsError_returnsUnderlyingError() {
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        BTPayPalDriver.setPayPalClass(FakePayPalOneTouchCore.self)
        BTPayPalDriver.payPalClass().cannedResult()?.cannedType = PayPalOneTouchResultType.Error
        let fakeError = NSError(domain: "FakeError", code: 1, userInfo: nil)
        BTPayPalDriver.payPalClass().cannedResult()?.cannedError = fakeError

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
    
    func testAppSwitchReturn_whenUserManuallyCancels_callsBackWithNoResultOrError() {
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        
        let expectation = expectationWithDescription("App switch return block invoked")
        payPalDriver.setAuthorizationAppSwitchReturnBlock { (tokenizedAccount, error) -> Void in
            XCTAssertNil(tokenizedAccount)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        // We simulate the user "manually cancelling" by posting a notification that the app has
        // become active
        NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationDidBecomeActiveNotification, object: nil)
        
        waitForExpectationsWithTimeout(2, handler: nil)
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
                XCTAssertEqual(tokenizedPayPalAccount!.shippingAddress.recipientName!, "Foo Bar")
                XCTAssertEqual(tokenizedPayPalAccount!.shippingAddress.streetAddress, "1 Foo Ct")
                XCTAssertEqual(tokenizedPayPalAccount!.shippingAddress.extendedAddress!, "Apt Bar")
                XCTAssertEqual(tokenizedPayPalAccount!.shippingAddress.locality, "Fubar")
                XCTAssertEqual(tokenizedPayPalAccount!.shippingAddress.region!, "FU")
                XCTAssertEqual(tokenizedPayPalAccount!.shippingAddress.postalCode!, "42")
                XCTAssertEqual(tokenizedPayPalAccount!.shippingAddress.countryCodeAlpha2, "USA")
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
    
    // MARK: _meta parameter
    
    func testMetaParameter_whenAuthorizationAppSwitchIsSuccessful_isPOSTedToServer() {
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        let stubPayPalClass = FakePayPalOneTouchCore.self
        stubPayPalClass.cannedResult()?.cannedType = .Success
        stubPayPalClass.setCannedIsWalletAppAvailable(true)
        BTPayPalDriver.setPayPalClass(stubPayPalClass)
        payPalDriver.setAuthorizationAppSwitchReturnBlock { _ -> Void in }
        BTPayPalDriver.handleAppSwitchReturnURL(NSURL(string: "bar://hello/world")!)
        
        XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v1/payment_methods/paypal_accounts")
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        let metaParameters = lastPostParameters["_meta"] as! NSDictionary
        XCTAssertEqual(metaParameters["source"] as? String, "paypal-app")
        XCTAssertEqual(metaParameters["integration"] as? String, "custom")
        XCTAssertEqual(metaParameters["sessionId"] as? String, mockAPIClient.metadata.sessionId)
    }
    
    func testMetaParameter_whenAuthorizationBrowserSwitchIsSuccessful_isPOSTedToServer() {
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        let stubPayPalClass = FakePayPalOneTouchCore.self
        stubPayPalClass.cannedResult()?.cannedType = .Success
        stubPayPalClass.setCannedIsWalletAppAvailable(false)
        BTPayPalDriver.setPayPalClass(stubPayPalClass)
        payPalDriver.setAuthorizationAppSwitchReturnBlock { _ -> Void in }
        BTPayPalDriver.handleAppSwitchReturnURL(NSURL(string: "bar://hello/world")!)
        
        XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v1/payment_methods/paypal_accounts")
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        let metaParameters = lastPostParameters["_meta"] as! NSDictionary
        XCTAssertEqual(metaParameters["source"] as? String, "paypal-browser")
        XCTAssertEqual(metaParameters["integration"] as? String, "custom")
        XCTAssertEqual(metaParameters["sessionId"] as? String, mockAPIClient.metadata.sessionId)
    }

    // MARK: Helpers

    func assertSuccessfulAuthorizationResponse(response: [String:AnyObject], assertionBlock: (BTTokenizedPayPalAccount?, NSError?) -> Void) {
        mockAPIClient.cannedResponseBody = BTJSON(value: response)
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        payPalDriver.clientMetadataId = FakePayPalOneTouchCore.clientMetadataID()
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        BTPayPalDriver.setPayPalClass(FakePayPalOneTouchCore.self)
        BTPayPalDriver.payPalClass().cannedResult()?.cannedType = .Success

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
    
    func testCheckout_whenAPIClientIsNil_callsBackWithError() {
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        payPalDriver.apiClient = nil
        
        let request = BTPayPalCheckoutRequest(amount: NSDecimalNumber(string: "1"))!
        let expectation = self.expectationWithDescription("Checkout fails with error")
        payPalDriver.checkoutWithCheckoutRequest(request) { (tokenizedPayPalCheckout, error) -> Void in
            XCTAssertNil(tokenizedPayPalCheckout)
            XCTAssertEqual(error!.domain, BTPayPalDriverErrorDomain)
            XCTAssertEqual(error!.code, BTPayPalDriverErrorType.Integration.rawValue)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testCheckout_whenRemoteConfigurationFetchFails_callsBackWithConfigurationError() {
        mockAPIClient.cannedConfigurationResponseBody = nil
        mockAPIClient.cannedConfigurationResponseError = NSError(domain: "", code: 0, userInfo: nil)
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        BTPayPalDriver.setPayPalClass(FakePayPalOneTouchCore.self)

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
        BTPayPalDriver.setPayPalClass(FakePayPalOneTouchCore.self)
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
    }

    func testCheckout_whenPayPalPaymentCreationSuccessful_performsAppSwitch() {
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        payPalDriver.returnURLScheme = "foo://"
        let mockRequestFactory = FakePayPalRequestFactory()
        payPalDriver.requestFactory = mockRequestFactory
        let delegate = MockAppSwitchDelegate(willPerform: self.expectationWithDescription("Delegate received willPerformAppSwitch"), didPerform: expectationWithDescription("Delegate received didPerformAppSwitch"))
        payPalDriver.delegate = delegate
        BTPayPalDriver.setPayPalClass(FakePayPalOneTouchCore.self)

        let request = BTPayPalCheckoutRequest(amount: NSDecimalNumber(string: "1"))!
        payPalDriver.checkoutWithCheckoutRequest(request) { _ -> Void in }

        self.waitForExpectationsWithTimeout(2, handler: nil)
        XCTAssertTrue(mockRequestFactory.checkoutRequest.appSwitchPerformed)
        XCTAssertEqual(payPalDriver.clientMetadataId, "fake-canned-metadata-id")
    }

    func testCheckout_whenPaymentResourceCreationFails_callsBackWithError() {
        mockAPIClient.cannedResponseError = NSError(domain: "", code: 0, userInfo: nil)

        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        payPalDriver.returnURLScheme = "foo://"
        BTPayPalDriver.setPayPalClass(FakePayPalOneTouchCore.self)
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

        BTPayPalDriver.setPayPalClass(FakePayPalOneTouchCore.self)
        BTPayPalDriver.payPalClass().cannedResult()?.cannedType = .Cancel
        payPalDriver.setCheckoutAppSwitchReturnBlock ({ (tokenizedCheckout, error) -> Void in
            XCTAssertNil(tokenizedCheckout)
            XCTAssertNil(error)
            continuationExpectation.fulfill()
        })

        BTPayPalDriver.handleAppSwitchReturnURL(returnURL)

        self.waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testCheckout_whenAppSwitchErrors_callsBackWithError() {
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        payPalDriver.returnURLScheme = "foo://"
        let returnURL = NSURL(string: "bar://hello/world")!

        let continuationExpectation = self.expectationWithDescription("Continuation called")

        BTPayPalDriver.setPayPalClass(FakePayPalOneTouchCore.self)
        BTPayPalDriver.payPalClass().cannedResult()?.cannedType = .Error
        BTPayPalDriver.payPalClass().cannedResult()?.cannedError = NSError(domain: "", code: 0, userInfo: nil)

        payPalDriver.setCheckoutAppSwitchReturnBlock ({ (tokenizedCheckout, error) -> Void in
            XCTAssertNil(tokenizedCheckout)
            XCTAssertEqual(error!, BTPayPalDriver.payPalClass().cannedResult()?.error!)
            continuationExpectation.fulfill()
            })

        BTPayPalDriver.handleAppSwitchReturnURL(returnURL)

        self.waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testCheckout_whenAppSwitchSucceeds_tokenizesPayPalCheckout() {
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        BTPayPalDriver.setPayPalClass(FakePayPalOneTouchCore.self)
        BTPayPalDriver.payPalClass().cannedResult()?.cannedType = .Success

        payPalDriver.setCheckoutAppSwitchReturnBlock ({ _ -> Void in })
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
        let delegate = MockAppSwitchDelegate()
        delegate.willProcess = expectationWithDescription("willProcessPaymentInfo called")
        payPalDriver.delegate = delegate
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        BTPayPalDriver.setPayPalClass(FakePayPalOneTouchCore.self)
        BTPayPalDriver.payPalClass().cannedResult()?.cannedType = .Success

        payPalDriver.setCheckoutAppSwitchReturnBlock ({ _ -> Void in })
        BTPayPalDriver.handleAppSwitchReturnURL(NSURL(string: "bar://hello/world")!)

        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testCheckout_whenAppSwitchResultIsError_returnsUnderlyingError() {
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        BTPayPalDriver.setPayPalClass(FakePayPalOneTouchCore.self)
        BTPayPalDriver.payPalClass().cannedResult()?.cannedType = .Error
        let fakeError = NSError(domain: "FakeError", code: 1, userInfo: nil)
        BTPayPalDriver.payPalClass().cannedResult()?.cannedError = fakeError

        let expectation = self.expectationWithDescription("App switch completion callback")
        payPalDriver.setCheckoutAppSwitchReturnBlock ({ (tokenizedCheckout, error) -> Void in
            guard let error = error else {
                XCTFail()
                return
            }
            XCTAssertEqual(error, fakeError)
            expectation.fulfill()
        })

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
                            "payerId": "FAKE-PAYER-ID",
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
                XCTAssertEqual(tokenizedPayPalCheckout!.payerId, "FAKE-PAYER-ID")
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

    // MARK: _meta parameter

    func testMetadata_whenCheckoutAppSwitchIsSuccessful_isPOSTedToServer() {
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        let stubPayPalClass = FakePayPalOneTouchCore.self
        stubPayPalClass.cannedResult()?.cannedType = .Success
        stubPayPalClass.setCannedIsWalletAppAvailable(true)
        BTPayPalDriver.setPayPalClass(stubPayPalClass)
        payPalDriver.setCheckoutAppSwitchReturnBlock ({ _ -> Void in })
        BTPayPalDriver.handleAppSwitchReturnURL(NSURL(string: "bar://hello/world")!)

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v1/payment_methods/paypal_accounts")
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        let metaParameters = lastPostParameters["_meta"] as! NSDictionary
        XCTAssertEqual(metaParameters["source"] as? String, "paypal-app")
        XCTAssertEqual(metaParameters["integration"] as? String, "custom")
        XCTAssertEqual(metaParameters["sessionId"] as? String, mockAPIClient.metadata.sessionId)
    }

    func testMetadata_whenCheckoutBrowserSwitchIsSuccessful_isPOSTedToServer() {
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        let stubPayPalClass = FakePayPalOneTouchCore.self
        stubPayPalClass.cannedResult()?.cannedType = .Success
        stubPayPalClass.setCannedIsWalletAppAvailable(false)
        BTPayPalDriver.setPayPalClass(stubPayPalClass)
        payPalDriver.setCheckoutAppSwitchReturnBlock ({ _ -> Void in })
        BTPayPalDriver.handleAppSwitchReturnURL(NSURL(string: "bar://hello/world")!)

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v1/payment_methods/paypal_accounts")
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        let metaParameters = lastPostParameters["_meta"] as! NSDictionary
        XCTAssertEqual(metaParameters["source"] as? String, "paypal-browser")
        XCTAssertEqual(metaParameters["integration"] as? String, "custom")
        XCTAssertEqual(metaParameters["sessionId"] as? String, mockAPIClient.metadata.sessionId)
    }

    // MARK: Helpers

    func assertSuccessfulCheckoutResponse(response: [String:AnyObject], assertionBlock: (BTTokenizedPayPalAccount?, NSError?) -> Void) {
        mockAPIClient.cannedResponseBody = BTJSON(value: response)
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        BTPayPalDriver.setPayPalClass(FakePayPalOneTouchCore.self)
        BTPayPalDriver.payPalClass().cannedResult()?.cannedType = .Success

        payPalDriver.setCheckoutAppSwitchReturnBlock ({ (tokenizedPayPalCheckout, error) -> Void in
            assertionBlock(tokenizedPayPalCheckout, error)
        })
        BTPayPalDriver.handleAppSwitchReturnURL(NSURL(string: "bar://hello/world")!)
    }

    // MARK: - Analytics
    
    func testAPIClientMetadata_whenWalletAppIsInstalled_hasSourceSetToPayPalApp() {
        // API client by default uses source = .Unknown and integration = .Custom
        let apiClient = BTAPIClient(clientKey: "development_testing_integration_merchant_id")!
        // It is critical to stub PayPalClass before instantiating the driver, since that is when source is set
        let stubPayPalClass = FakePayPalOneTouchCore.self
        stubPayPalClass.setCannedIsWalletAppAvailable(true)
        BTPayPalDriver.setPayPalClass(stubPayPalClass)
        let payPalDriver = BTPayPalDriver(APIClient: apiClient)
        
        XCTAssertEqual(payPalDriver.apiClient?.metadata.integration, BTClientMetadataIntegrationType.Custom)
        XCTAssertEqual(payPalDriver.apiClient?.metadata.source, BTClientMetadataSourceType.PayPalApp)
    }
    
    func testAPIClientMetadata_whenWalletAppIsNotAvailable_hasSourceSetToPayPalBrowser() {
        let apiClient = BTAPIClient(clientKey: "development_testing_integration_merchant_id")!
        let stubPayPalClass = FakePayPalOneTouchCore.self
        stubPayPalClass.setCannedIsWalletAppAvailable(false)
        BTPayPalDriver.setPayPalClass(stubPayPalClass)
        let payPalDriver = BTPayPalDriver(APIClient: apiClient)
        
        XCTAssertEqual(payPalDriver.apiClient?.metadata.integration, BTClientMetadataIntegrationType.Custom)
        XCTAssertEqual(payPalDriver.apiClient?.metadata.source, BTClientMetadataSourceType.PayPalBrowser)
    }
}

// MARK: - Billing Agreements

class BTPayPalDriver_BillingAgreements_Tests: XCTestCase {
    
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
    
    func testBillingAgreement_whenAPIClientIsNil_callsBackWithError() {
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        payPalDriver.apiClient = nil
        
        let request = BTPayPalCheckoutRequest(amount: NSDecimalNumber(string: "1"))!
        let expectation = self.expectationWithDescription("Billing Agreement fails with error")
        payPalDriver.billingAgreementWithCheckoutRequest(request) { (tokenizedPayPalCheckout, error) -> Void in
            XCTAssertNil(tokenizedPayPalCheckout)
            XCTAssertEqual(error!.domain, BTPayPalDriverErrorDomain)
            XCTAssertEqual(error!.code, BTPayPalDriverErrorType.Integration.rawValue)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testBillingAgreement_whenRemoteConfigurationFetchFails_callsBackWithConfigurationError() {
        mockAPIClient.cannedConfigurationResponseBody = nil
        mockAPIClient.cannedConfigurationResponseError = NSError(domain: "", code: 0, userInfo: nil)
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        BTPayPalDriver.setPayPalClass(FakePayPalOneTouchCore.self)
        
        let request = BTPayPalCheckoutRequest()
        let expectation = self.expectationWithDescription("Checkout fails with error")
        payPalDriver.billingAgreementWithCheckoutRequest(request) { (_, error) -> Void in
            XCTAssertEqual(error!, self.mockAPIClient.cannedConfigurationResponseError!)
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testBillingAgreement_whenRemoteConfigurationFetchSucceeds_postsSetupBillingAgreement() {
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        payPalDriver.returnURLScheme = "foo://"
        BTPayPalDriver.setPayPalClass(FakePayPalOneTouchCore.self)

        payPalDriver.billingAgreementWithCheckoutRequest(BTPayPalCheckoutRequest()) { _ -> Void in }
        
        XCTAssertEqual("v1/paypal_hermes/setup_billing_agreement", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        XCTAssertEqual(lastPostParameters["return_url"] as? String, "scheme://return")
        XCTAssertEqual(lastPostParameters["cancel_url"] as? String, "scheme://cancel")
    }
    
    func testBillingAgreement_whenAppSwitchSucceeds_tokenizesPayPalAccount() {
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        BTPayPalDriver.setPayPalClass(FakePayPalOneTouchCore.self)
        BTPayPalDriver.payPalClass().cannedResult()?.cannedType = .Success
        
        payPalDriver.setBillingAgreementAppSwitchReturnBlock ({ _ -> Void in })
        BTPayPalDriver.handleAppSwitchReturnURL(NSURL(string: "bar://hello/world")!)
        
        XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v1/payment_methods/paypal_accounts")
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        let paypalAccount = lastPostParameters["paypal_account"] as! NSDictionary
        XCTAssertEqual(paypalAccount, FakePayPalOneTouchCoreResult().response)
    }
    
    func testBillingAgreement_whenConfigurationHasCurrency_doesNotSendCurrencyViaPOSTParameters() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "paypal": [
                "environment": "offline",
                "currencyIsoCode": "GBP",
            ] ])
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        payPalDriver.returnURLScheme = "foo://"
        BTPayPalDriver.setPayPalClass(FakePayPalOneTouchCore.self)
        
        payPalDriver.billingAgreementWithCheckoutRequest(BTPayPalCheckoutRequest()) { _ -> Void in }
        
        XCTAssertEqual("v1/paypal_hermes/setup_billing_agreement", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        XCTAssertTrue(lastPostParameters["currency_iso_code"] == nil)
    }
    
    func testBillingAgreement_whenCheckoutRequestHasCurrency_doesNotSendCurrencyViaPOSTParameters() {
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        payPalDriver.returnURLScheme = "foo://"
        BTPayPalDriver.setPayPalClass(FakePayPalOneTouchCore.self)
        let checkoutRequest = BTPayPalCheckoutRequest()
        checkoutRequest.currencyCode = "GBP"
        
        payPalDriver.billingAgreementWithCheckoutRequest(checkoutRequest) { _ -> Void in }
        
        XCTAssertEqual("v1/paypal_hermes/setup_billing_agreement", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        XCTAssertTrue(lastPostParameters["currency_iso_code"] == nil)
    }
    
    func testBillingAgreement_whenSetupBillingAgreementCreationSuccessful_performsAppSwitch() {
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        payPalDriver.returnURLScheme = "foo://"
        let mockRequestFactory = FakePayPalRequestFactory()
        payPalDriver.requestFactory = mockRequestFactory
        let delegate = MockAppSwitchDelegate(willPerform: self.expectationWithDescription("Delegate received willPerformAppSwitch"), didPerform: expectationWithDescription("Delegate received didPerformAppSwitch"))
        payPalDriver.delegate = delegate
        BTPayPalDriver.setPayPalClass(FakePayPalOneTouchCore.self)
        
        let request = BTPayPalCheckoutRequest()
        payPalDriver.billingAgreementWithCheckoutRequest(request) { _ -> Void in }
        
        self.waitForExpectationsWithTimeout(2, handler: nil)
        XCTAssertTrue(mockRequestFactory.billingAgreementRequest.appSwitchPerformed)
    }
    
    func testBillingAgreement_whenSetupBillingAgreementCreationFails_callsBackWithError() {
        mockAPIClient.cannedResponseError = NSError(domain: "", code: 0, userInfo: nil)
        
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        mockAPIClient = payPalDriver.apiClient as! MockAPIClient
        payPalDriver.returnURLScheme = "foo://"
        BTPayPalDriver.setPayPalClass(FakePayPalOneTouchCore.self)
        let dummyRequest = BTPayPalCheckoutRequest()
        let expectation = self.expectationWithDescription("Checkout fails with error")
        payPalDriver.billingAgreementWithCheckoutRequest(dummyRequest) { (_, error) -> Void in
            XCTAssertEqual(error!, self.mockAPIClient.cannedResponseError!)
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testViewControllerPresentationDelegateMethodsCalled() {
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        let viewControllerPresentingDelegate = MockViewControllerPresentationDelegate()
        
        // Setup for requestsPersentationOfViewController
        viewControllerPresentingDelegate.requestsPresentationOfViewController = self.expectationWithDescription("Delegate received requestsPresentationOfViewController")
        
        payPalDriver.viewControllerPresentingDelegate = viewControllerPresentingDelegate
        payPalDriver.informDelegatePresentingViewControllerRequestPresent(NSURL(string: "http://example.com")!)
        
        self.waitForExpectationsWithTimeout(2, handler: nil)
        
        XCTAssertTrue(viewControllerPresentingDelegate.lastViewController is SFSafariViewController)
        XCTAssertEqual(viewControllerPresentingDelegate.lastViewController, payPalDriver.safariViewController)
        let payPalDriverViewControllerPresented = payPalDriver.safariViewController
        XCTAssertEqual(viewControllerPresentingDelegate.lastPaymentDriver as? BTPayPalDriver, payPalDriver)
        
        viewControllerPresentingDelegate.lastViewController = nil
        viewControllerPresentingDelegate.lastPaymentDriver = nil

        // Setup for requestsDismissalOfViewController
        viewControllerPresentingDelegate.requestsDismissalOfViewController = self.expectationWithDescription("Delegate received requestsDismissalOfViewController")
        payPalDriver.informDelegatePresentingViewControllerNeedsDismissal()
        
        self.waitForExpectationsWithTimeout(2, handler: nil)

        XCTAssertTrue(viewControllerPresentingDelegate.lastViewController is SFSafariViewController)
        XCTAssertEqual(viewControllerPresentingDelegate.lastViewController as? SFSafariViewController, payPalDriverViewControllerPresented)
        XCTAssertNil(payPalDriver.safariViewController)

        XCTAssertEqual(viewControllerPresentingDelegate.lastPaymentDriver as? BTPayPalDriver, payPalDriver)
    }
    
    func testViewControllerPresentationDelegateMethodsCalledButNoViewControllerPresentingDelegateSet() {
        let payPalDriver = BTPayPalDriver(APIClient: mockAPIClient)
        
        var warningMessageLogged = false
        BTLogger.sharedLogger().logBlock = {
            (level: BTLogLevel, message: String!) in
            if (level == BTLogLevel.Warning && message == "Unable to display View Controller to continue PayPal flow. BTPayPalDriver needs a viewControllerPresentingDelegate<BTViewControllerPresentingDelegate> to be set.") {
                warningMessageLogged = true
            }
            return
        }

        payPalDriver.informDelegatePresentingViewControllerRequestPresent(NSURL(string: "http://example.com")!)
        XCTAssertTrue(warningMessageLogged)
    }

}

class BTPayPalDriver_DropIn_Tests: XCTestCase {
    
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
    
    func testDropInViewDelegateSet() {
        let dropInViewController = BTDropInViewController(APIClient: mockAPIClient)

        var paymentButton : BTPaymentButton? = nil
        for subView in dropInViewController.view.subviews.first!.subviews.first!.subviews {
            if let view = subView as? BTPaymentButton {
                paymentButton = view
            }
        }
        
        XCTAssertNotNil(paymentButton)
        XCTAssertNotNil(paymentButton?.viewControllerPresentingDelegate)
        XCTAssertEqual(paymentButton?.viewControllerPresentingDelegate as? BTDropInViewController, dropInViewController)
    }

}
