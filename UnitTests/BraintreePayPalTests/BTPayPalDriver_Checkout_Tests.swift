import XCTest
import BraintreePayPal
import BraintreeTestShared
import SafariServices

class BTPayPalDriver_Checkout_Tests: XCTestCase {
    var mockAPIClient: MockAPIClient!
    var payPalDriver: BTPayPalDriver!

    override func setUp() {
        super.setUp()

        mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "paypal": [
                "environment": "offline"
            ]
        ])
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": [
                "redirectUrl": "http://fakeURL.com"
            ]
        ])

        payPalDriver = BTPayPalDriver(apiClient: mockAPIClient)
    }

    func testCheckout_whenAPIClientIsNil_callsBackWithError() {
        payPalDriver.apiClient = nil

        let request = BTPayPalCheckoutRequest(amount: "1")
        let expectation = self.expectation(description: "Checkout fails with error")

        payPalDriver.requestOneTimePayment(request) { (nonce, error) in
            guard let error = error as NSError? else { XCTFail(); return }
            XCTAssertNil(nonce)
            XCTAssertEqual(error.domain, BTPayPalDriverErrorDomain)
            XCTAssertEqual(error.code, BTPayPalDriverErrorType.integration.rawValue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testCheckout_whenRemoteConfigurationFetchFails_callsBackWithConfigurationError() {
        mockAPIClient.cannedConfigurationResponseBody = nil
        mockAPIClient.cannedConfigurationResponseError = NSError(domain: "", code: 0, userInfo: nil)

        let request = BTPayPalCheckoutRequest(amount: "1")
        let expectation = self.expectation(description: "Checkout fails with error")

        payPalDriver.requestOneTimePayment(request) { (nonce, error) in
            guard let error = error as NSError? else { XCTFail(); return }
            XCTAssertNil(nonce)
            XCTAssertEqual(error, self.mockAPIClient.cannedConfigurationResponseError)
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1)
    }

    // MARK: - POST request to Hermes endpoint

    func testCheckout_whenRemoteConfigurationFetchSucceeds_postsToCorrectEndpoint() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        request.intent = .sale

        payPalDriver.requestOneTimePayment(request) { _,_  -> Void in }

        XCTAssertEqual("v1/paypal_hermes/create_payment_resource", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else { XCTFail(); return }

        XCTAssertEqual(lastPostParameters["intent"] as? String, "sale")
        XCTAssertEqual(lastPostParameters["amount"] as? String, "1")
        XCTAssertEqual(lastPostParameters["return_url"] as? String, "sdk.ios.braintree://onetouch/v1/success")
        XCTAssertEqual(lastPostParameters["cancel_url"] as? String, "sdk.ios.braintree://onetouch/v1/cancel")
    }

    func testCheckout_whenPaymentResourceCreationFails_callsBackWithError() {
        mockAPIClient.cannedResponseError = NSError(domain: "", code: 0, userInfo: nil)

        let dummyRequest = BTPayPalCheckoutRequest(amount: "1")
        let expectation = self.expectation(description: "Checkout fails with error")
        payPalDriver.requestOneTimePayment(dummyRequest) { (_, error) -> Void in
            XCTAssertEqual(error! as NSError, self.mockAPIClient.cannedResponseError!)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 1)
    }

    // MARK: - PayPal approval URL to present in browser

    func testCheckout_whenUserActionIsNotSet_approvalUrlIsNotModified() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": [
                "redirectUrl": "https://www.paypal.com/checkout?EC-Token=EC-Random-Value"
            ]
        ])

        let request = BTPayPalCheckoutRequest(amount: "1")
        payPalDriver.requestOneTimePayment(request) { (_, _) in }

        XCTAssertEqual("https://www.paypal.com/checkout?EC-Token=EC-Random-Value", payPalDriver.approvalUrl.absoluteString)
    }

    func testCheckout_whenUserActionIsSetToDefault_approvalUrlIsNotModified() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": [
                "redirectUrl": "https://www.paypal.com/checkout?EC-Token=EC-Random-Value"
            ]
        ])

        let request = BTPayPalCheckoutRequest(amount: "1")
        request.userAction = BTPayPalRequestUserAction.default

        payPalDriver.requestOneTimePayment(request) { (_, _) in }

        XCTAssertEqual("https://www.paypal.com/checkout?EC-Token=EC-Random-Value", payPalDriver.approvalUrl.absoluteString)
    }

    func testCheckout_whenUserActionIsSetToCommit_approvalUrlIsModified() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": [
                "redirectUrl": "https://www.paypal.com/checkout?EC-Token=EC-Random-Value"
            ]
        ])

        let request = BTPayPalCheckoutRequest(amount: "1")
        request.userAction = BTPayPalRequestUserAction.commit

        payPalDriver.requestOneTimePayment(request) { (_, _) in }

        XCTAssertEqual("https://www.paypal.com/checkout?EC-Token=EC-Random-Value&useraction=commit", payPalDriver.approvalUrl.absoluteString)
    }

    // MARK: - Browser switch

    func testCheckout_whenPayPalCreditOffered_performsSwitchCorrectly() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        request.currencyCode = "GBP"
        request.offerCredit = true

        payPalDriver.requestOneTimePayment(request) { _,_  in }

        XCTAssertNotNil(payPalDriver.authenticationSession)
        XCTAssertTrue(payPalDriver.isAuthenticationSessionStarted)

        // Ensure the payment resource had the correct parameters
        XCTAssertEqual("v1/paypal_hermes/create_payment_resource", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        XCTAssertEqual(lastPostParameters["offer_paypal_credit"] as? Bool, true)

        // Make sure analytics event was sent when switch occurred
        let postedAnalyticsEvents = mockAPIClient.postedAnalyticsEvents

        XCTAssertTrue(postedAnalyticsEvents.contains("ios.paypal-single-payment.webswitch.credit.offered.started"))
    }

    func testCheckout_whenPayPalPayLaterOffered_performsSwitchCorrectly() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        request.currencyCode = "GBP"
        request.offerPayLater = true

        payPalDriver.requestOneTimePayment(request) { _,_  in }

        XCTAssertNotNil(payPalDriver.authenticationSession)
        XCTAssertTrue(payPalDriver.isAuthenticationSessionStarted)

        // Ensure the payment resource had the correct parameters
        XCTAssertEqual("v1/paypal_hermes/create_payment_resource", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        XCTAssertEqual(lastPostParameters["offer_pay_later"] as? Bool, true)

        // Make sure analytics event was sent when switch occurred
        let postedAnalyticsEvents = mockAPIClient.postedAnalyticsEvents

        XCTAssertTrue(postedAnalyticsEvents.contains("ios.paypal-single-payment.webswitch.paylater.offered.started"))
    }

    func testCheckout_whenPayPalPaymentCreationSuccessful_performsAppSwitch() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        payPalDriver.requestOneTimePayment(request) { _,_  -> Void in }

        XCTAssertNotNil(payPalDriver.authenticationSession)
        XCTAssertTrue(payPalDriver.isAuthenticationSessionStarted)

        XCTAssertNotNil(payPalDriver.clientMetadataID)
    }

    func testCheckout_whenBrowserSwitchCancels_callsBackWithNoResultAndError() {
        let returnURL = URL(string: "bar://onetouch/v1/cancel?token=hermes_token")!

        let expectation = self.expectation(description: "completion block called")

        payPalDriver.handleBrowserSwitchReturn(returnURL, paymentType: .checkout) { (nonce, error) in
            XCTAssertNil(nonce)
            XCTAssertEqual((error! as NSError).domain, BTPayPalDriverErrorDomain)
            XCTAssertEqual((error! as NSError).code, BTPayPalDriverErrorType.canceled.rawValue)
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1)
    }

    func testCheckout_whenBrowserSwitchHasInvalidReturnURL_callsBackWithError() {
        let returnURL = URL(string: "bar://onetouch/v1/invalid")!

        let continuationExpectation = self.expectation(description: "Continuation called")

        payPalDriver.handleBrowserSwitchReturn(returnURL, paymentType: .checkout) { (nonce, error) in
            guard let error = error as NSError? else { XCTFail(); return }
            XCTAssertNil(nonce)
            XCTAssertNotNil(error)
            XCTAssertEqual(error.domain, BTPayPalDriverErrorDomain)
            XCTAssertEqual(error.code, BTPayPalDriverErrorType.unknown.rawValue)
            continuationExpectation.fulfill()
        }

        self.waitForExpectations(timeout: 1)
    }

    func testCheckout_whenBrowserSwitchSucceeds_tokenizesPayPalCheckout() {
        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        payPalDriver.handleBrowserSwitchReturn(returnURL, paymentType: .checkout) { (_, _) in }

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v1/payment_methods/paypal_accounts")

        let lastPostParameters = mockAPIClient.lastPOSTParameters!
        let paypalAccount = lastPostParameters["paypal_account"] as! [String:Any]
        let options = paypalAccount["options"] as! [String:Any]
        XCTAssertFalse(options["validate"] as! Bool)
    }

    func testCheckout_whenBrowserSwitchSucceeds_intentShouldExistAsPayPalAccountParameter() {
        let payPalRequest = BTPayPalCheckoutRequest(amount: "1.34")
        payPalRequest.intent = .sale
        payPalDriver.payPalRequest = payPalRequest

        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        payPalDriver.handleBrowserSwitchReturn(returnURL, paymentType: .checkout) { (_, _) in }

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v1/payment_methods/paypal_accounts")

        let lastPostParameters = mockAPIClient.lastPOSTParameters!
        let paypalAccount = lastPostParameters["paypal_account"] as! [String:Any]
        XCTAssertEqual(paypalAccount["intent"] as? String, "sale")

        let options = paypalAccount["options"] as! [String:Any]
        XCTAssertFalse(options["validate"] as! Bool)
    }

    func testCheckout_whenBrowserSwitchSucceeds_merchantAccountIdIsSet() {
        let merchantAccountID = "alternate-merchant-account-id"
        payPalDriver.payPalRequest = BTPayPalCheckoutRequest(amount: "1.34")
        payPalDriver.payPalRequest.merchantAccountID = merchantAccountID

        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        payPalDriver.handleBrowserSwitchReturn(returnURL, paymentType: .checkout) { (_, _) in }

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v1/payment_methods/paypal_accounts")
        let lastPostParameters = mockAPIClient.lastPOSTParameters!
        XCTAssertEqual(lastPostParameters["merchant_account_id"] as? String, merchantAccountID)
    }

    func testCheckout_whenCreditFinancingNotReturned_shouldNotSendCreditAcceptedAnalyticsEvent() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [ "paypalAccounts":
            [
                [
                    "description": "jane.doe@example.com",
                    "details": [
                        "email": "jane.doe@example.com",
                    ],
                    "nonce": "a-nonce",
                    "type": "PayPalAccount",
                    ]
                ]
        ])
        payPalDriver.payPalRequest = BTPayPalCheckoutRequest(amount: "1.34")

        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        payPalDriver.handleBrowserSwitchReturn(returnURL, paymentType: .checkout) { (_, _) in }

        XCTAssertFalse(mockAPIClient.postedAnalyticsEvents.contains("ios.paypal-single-payment.credit.accepted"))
    }

    func testCheckout_whenCreditFinancingReturned_shouldSendCreditAcceptedAnalyticsEvent() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [ "paypalAccounts":
            [
                [
                    "description": "jane.doe@example.com",
                    "details": [
                        "email": "jane.doe@example.com",
                        "creditFinancingOffered": [
                            "cardAmountImmutable": true,
                            "monthlyPayment": [
                                "currency": "USD",
                                "value": "13.88",
                            ],
                            "payerAcceptance": true,
                            "term": 18,
                            "totalCost": [
                                "currency": "USD",
                                "value": "250.00",
                            ],
                            "totalInterest": [
                                "currency": "USD",
                                "value": "0.00",
                            ],
                        ],
                    ],
                    "nonce": "a-nonce",
                    "type": "PayPalAccount",
                ]
            ]
        ])
        payPalDriver.payPalRequest = BTPayPalCheckoutRequest(amount: "1.34")

        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        payPalDriver.handleBrowserSwitchReturn(returnURL, paymentType: .checkout) { (_, _) in }

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("ios.paypal-single-payment.credit.accepted"))
    }

    func testCheckout_whenBrowserSwitchSucceeds_makesDelegateCallback() {
        let delegate = MockAppSwitchDelegate()
        delegate.appContextDidReturnExpectation = expectation(description: "appContextDidReturn called")
        payPalDriver.appSwitchDelegate = delegate

        let returnURL = URL(string: "bar://hello/world")!
        payPalDriver.handleBrowserSwitchReturn(returnURL, paymentType: .checkout) { (_, _) in }

        waitForExpectations(timeout: 1)

        XCTAssertTrue(delegate.lastAppSwitcher is BTPayPalDriver)
        XCTAssertTrue(delegate.appContextDidReturnCalled)
    }

    // MARK: - Tokenization

    func testTokenizedPayPalAccount_containsPayerInfo() {
        let checkoutResponse = [
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
                ] ] ]
        assertSuccessfulCheckoutResponse(checkoutResponse as [String : AnyObject],
            assertionBlock: { (tokenizedPayPalAccount, error) -> Void in
                XCTAssertEqual(tokenizedPayPalAccount!.nonce, "a-nonce")
                XCTAssertEqual(tokenizedPayPalAccount!.firstName, "Some")
                XCTAssertEqual(tokenizedPayPalAccount!.lastName, "Dude")
                XCTAssertEqual(tokenizedPayPalAccount!.phone, "867-5309")
                XCTAssertEqual(tokenizedPayPalAccount!.email, "hello@world.com")
                XCTAssertEqual(tokenizedPayPalAccount!.payerID, "FAKE-PAYER-ID")
                let billingAddress = tokenizedPayPalAccount!.billingAddress!
                let shippingAddress = tokenizedPayPalAccount!.shippingAddress!
                XCTAssertEqual(billingAddress.recipientName, "Bar Foo")
                XCTAssertEqual(billingAddress.streetAddress, "2 Foo Ct")
                XCTAssertEqual(billingAddress.extendedAddress, "Apt Foo")
                XCTAssertEqual(billingAddress.locality, "Barfoo")
                XCTAssertEqual(billingAddress.region, "BF")
                XCTAssertEqual(billingAddress.postalCode, "24")
                XCTAssertEqual(billingAddress.countryCodeAlpha2, "ASU")
                XCTAssertEqual(shippingAddress.recipientName, "Some Dude")
                XCTAssertEqual(shippingAddress.streetAddress, "3 Foo Ct")
                XCTAssertEqual(shippingAddress.extendedAddress, "Apt 5")
                XCTAssertEqual(shippingAddress.locality, "Dudeville")
                XCTAssertEqual(shippingAddress.region, "CA")
                XCTAssertEqual(shippingAddress.postalCode, "24")
                XCTAssertEqual(shippingAddress.countryCodeAlpha2, "US")
        })
    }

    func testTokenizedPayPalAccount_whenEmailAddressIsNestedInsidePayerInfoJSON_usesNestedEmailAddress() {
        let checkoutResponse = [
            "paypalAccounts": [
                [
                    "nonce": "fake-nonce",
                    "details": [
                        "email": "not-hello@world.com",
                        "payerInfo": [
                            "email": "hello@world.com",
                        ]
                    ],
                ]
            ]
        ]
        assertSuccessfulCheckoutResponse(checkoutResponse as [String : AnyObject],
            assertionBlock: { (tokenizedPayPalAccount, error) -> Void in
                XCTAssertEqual(tokenizedPayPalAccount!.email, "hello@world.com")
        })
    }

    // MARK: - _meta parameter

    func testMetadata_whenCheckoutBrowserSwitchIsSuccessful_isPOSTedToServer() {
        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        payPalDriver.handleBrowserSwitchReturn(returnURL, paymentType: .checkout) { (_, _) in }

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v1/payment_methods/paypal_accounts")
        let lastPostParameters = mockAPIClient.lastPOSTParameters!
        let metaParameters = lastPostParameters["_meta"] as! [String:Any]
        XCTAssertEqual(metaParameters["source"] as? String, "paypal-browser")
        XCTAssertEqual(metaParameters["integration"] as? String, "custom")
        XCTAssertEqual(metaParameters["sessionId"] as? String, mockAPIClient.metadata.sessionID)
    }

    // MARK: - Analytics

    func testAPIClientMetadata_hasSourceSetToPayPalBrowser() {
        let apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")!
        let payPalDriver = BTPayPalDriver(apiClient: apiClient)

        XCTAssertEqual(payPalDriver.apiClient?.metadata.integration, BTClientMetadataIntegrationType.custom)
        XCTAssertEqual(payPalDriver.apiClient?.metadata.source, BTClientMetadataSourceType.payPalBrowser)
    }

    // MARK: - Helpers

    func assertSuccessfulCheckoutResponse(_ response: [String:AnyObject], assertionBlock: @escaping (BTPayPalAccountNonce?, NSError?) -> Void) {
        mockAPIClient.cannedResponseBody = BTJSON(value: response)

        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        payPalDriver.handleBrowserSwitchReturn(returnURL, paymentType: .checkout) { (tokenizedPayPalAccount, error) in
            assertionBlock(tokenizedPayPalAccount, error as NSError?)
        }
    }
}
