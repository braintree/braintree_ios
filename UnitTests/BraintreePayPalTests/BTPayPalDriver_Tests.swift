import XCTest
import BraintreePayPal
import BraintreeTestShared

class BTPayPalDriver_Tests: XCTestCase {
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

    func testTokenizePayPalAccount_whenAPIClientIsNil_callsBackWithError() {
        payPalDriver.apiClient = nil

        let request = BTPayPalCheckoutRequest(amount: "1")
        let expectation = self.expectation(description: "Checkout fails with error")

        payPalDriver.tokenizePayPalAccount(with: request) { (nonce, error) in
            guard let error = error as NSError? else { XCTFail(); return }
            XCTAssertNil(nonce)
            XCTAssertEqual(error.domain, BTPayPalDriverErrorDomain)
            XCTAssertEqual(error.code, BTPayPalDriverErrorType.integration.rawValue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testTokenizePayPalAccount_whenRequestIsNotExpectedSubclass_callsBackWithError() {
        let request = BTPayPalRequest() // not one of our subclasses
        let expectation = self.expectation(description: "Checkout fails with error")

        payPalDriver.tokenizePayPalAccount(with: request) { (nonce, error) in
            guard let error = error as NSError? else { XCTFail(); return }
            XCTAssertNil(nonce)
            XCTAssertEqual(error.domain, BTPayPalDriverErrorDomain)
            XCTAssertEqual(error.code, BTPayPalDriverErrorType.integration.rawValue)
            XCTAssertEqual(error.localizedDescription, "BTPayPalDriver failed because request is not of type BTPayPalCheckoutRequest or BTPayPalVaultRequest.")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testTokenizePayPalAccount_whenRemoteConfigurationFetchFails_callsBackWithConfigurationError() {
        mockAPIClient.cannedConfigurationResponseBody = nil
        mockAPIClient.cannedConfigurationResponseError = NSError(domain: "", code: 0, userInfo: nil)

        let request = BTPayPalCheckoutRequest(amount: "1")
        let expectation = self.expectation(description: "Checkout fails with error")

        payPalDriver.tokenizePayPalAccount(with: request) { (nonce, error) in
            guard let error = error as NSError? else { XCTFail(); return }
            XCTAssertNil(nonce)
            XCTAssertEqual(error, self.mockAPIClient.cannedConfigurationResponseError)
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1)
    }

    func testTokenizePayPalAccount_whenPayPalNotEnabledInConfiguration_callsBackWithError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": false
        ])

        let request = BTPayPalCheckoutRequest(amount: "1")
        let expectation = self.expectation(description: "Checkout fails with error")

        payPalDriver.tokenizePayPalAccount(with: request) { (nonce, error) in
            guard let error = error as NSError? else { XCTFail(); return }
            XCTAssertNil(nonce)
            XCTAssertEqual(error.domain, BTPayPalDriverErrorDomain)
            XCTAssertEqual(error.code, BTPayPalDriverErrorType.disabled.rawValue)
            XCTAssertEqual(error.localizedDescription, "PayPal is not enabled for this merchant")
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1)
    }

    // MARK: - POST request to Hermes endpoint

    func testRequestOneTimePayment_whenRemoteConfigurationFetchSucceeds_postsToCorrectEndpoint() {
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

    func testRequestBillingAgreement_whenRemoteConfigurationFetchSucceeds_postsToCorrectEndpoint() {
        let request = BTPayPalVaultRequest()
        request.billingAgreementDescription = "description"

        payPalDriver.requestBillingAgreement(request) { _,_  -> Void in }

        XCTAssertEqual("v1/paypal_hermes/setup_billing_agreement", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else { XCTFail(); return }

        XCTAssertEqual(lastPostParameters["description"] as? String, "description")
        XCTAssertEqual(lastPostParameters["return_url"] as? String, "sdk.ios.braintree://onetouch/v1/success")
        XCTAssertEqual(lastPostParameters["cancel_url"] as? String, "sdk.ios.braintree://onetouch/v1/cancel")
    }

    func testTokenizePayPalAccount_whenPaymentResourceCreationFails_callsBackWithError() {
        mockAPIClient.cannedResponseError = NSError(domain: "", code: 0, userInfo: nil)

        let dummyRequest = BTPayPalCheckoutRequest(amount: "1")
        let expectation = self.expectation(description: "Checkout fails with error")
        payPalDriver.tokenizePayPalAccount(with: dummyRequest) { (_, error) -> Void in
            XCTAssertEqual(error! as NSError, self.mockAPIClient.cannedResponseError!)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 1)
    }

    // MARK: - PayPal approval URL to present in browser

    func testTokenizePayPalAccount_checkout_whenUserActionIsNotSet_approvalUrlIsNotModified() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": [
                "redirectUrl": "https://www.paypal.com/checkout?EC-Token=EC-Random-Value"
            ]
        ])

        let request = BTPayPalCheckoutRequest(amount: "1")
        payPalDriver.tokenizePayPalAccount(with: request) { (_, _) in }

        XCTAssertEqual("https://www.paypal.com/checkout?EC-Token=EC-Random-Value", payPalDriver.approvalUrl.absoluteString)
    }

    func testTokenizePayPalAccount_vault_whenUserActionIsNotSet_approvalUrlIsNotModified() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "agreementSetup": [
                "approvalUrl": "https://checkout.paypal.com/one-touch-login-sandbox"
            ]
        ])

        let request = BTPayPalVaultRequest()
        payPalDriver.tokenizePayPalAccount(with: request) { (_, _) in }

        XCTAssertEqual("https://checkout.paypal.com/one-touch-login-sandbox", payPalDriver.approvalUrl.absoluteString)
    }

    func testTokenizePayPalAccount_whenUserActionIsSetToDefault_approvalUrlIsNotModified() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": [
                "redirectUrl": "https://www.paypal.com/checkout?EC-Token=EC-Random-Value"
            ]
        ])

        let request = BTPayPalCheckoutRequest(amount: "1")
        request.userAction = BTPayPalRequestUserAction.default

        payPalDriver.tokenizePayPalAccount(with: request) { (_, _) in }

        XCTAssertEqual("https://www.paypal.com/checkout?EC-Token=EC-Random-Value", payPalDriver.approvalUrl.absoluteString)
    }

    func testTokenizePayPalAccount_whenUserActionIsSetToCommit_approvalUrlIsModified() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": [
                "redirectUrl": "https://www.paypal.com/checkout?EC-Token=EC-Random-Value"
            ]
        ])

        let request = BTPayPalCheckoutRequest(amount: "1")
        request.userAction = BTPayPalRequestUserAction.commit

        payPalDriver.tokenizePayPalAccount(with: request) { (_, _) in }

        XCTAssertEqual("https://www.paypal.com/checkout?EC-Token=EC-Random-Value&useraction=commit", payPalDriver.approvalUrl.absoluteString)
    }

    func testTokenizePayPalAccount_whenUserActionIsSetToCommit_andNoQueryParamsArePresent_approvalUrlIsModified() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": [
                "redirectUrl": "https://www.paypal.com/checkout"
            ]
        ])

        let request = BTPayPalCheckoutRequest(amount: "1")
        request.userAction = BTPayPalRequestUserAction.commit

        payPalDriver.tokenizePayPalAccount(with: request) { (_, _) in }

        XCTAssertEqual("https://www.paypal.com/checkout?useraction=commit", payPalDriver.approvalUrl.absoluteString)
    }

    func testTokenizePayPalAccount_whenApprovalUrlIsNotHTTP_returnsError() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": [
                "redirectUrl": "file://some-url.com"
            ]
        ])

        let request = BTPayPalCheckoutRequest(amount: "1")
        let expectation = self.expectation(description: "Returns error")

        payPalDriver.tokenizePayPalAccount(with: request) { (nonce, error) in
            XCTAssertNil(nonce)
            XCTAssertEqual((error! as NSError).domain, BTPayPalDriverErrorDomain)
            XCTAssertEqual((error! as NSError).code, BTPayPalDriverErrorType.unknown.rawValue)
            XCTAssertEqual((error! as NSError).localizedDescription, "Attempted to open an invalid URL in ASWebAuthenticationSession: file://")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    // MARK: - Browser switch

    func testTokenizePayPalAccount_whenPayPalPayLaterOffered_performsSwitchCorrectly() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        request.currencyCode = "GBP"
        request.offerPayLater = true

        payPalDriver.tokenizePayPalAccount(with: request) { _,_  in }

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

    func testTokenizePayPalAccount_whenPayPalCreditOffered_performsSwitchCorrectly() {
        let request = BTPayPalVaultRequest()
        request.offerCredit = true

        payPalDriver.tokenizePayPalAccount(with: request) { _,_  in }

        XCTAssertNotNil(payPalDriver.authenticationSession)
        XCTAssertTrue(payPalDriver.isAuthenticationSessionStarted)

        // Ensure the payment resource had the correct parameters
        XCTAssertEqual("v1/paypal_hermes/setup_billing_agreement", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        XCTAssertEqual(lastPostParameters["offer_paypal_credit"] as? Bool, true)

        // Make sure analytics event was sent when switch occurred
        let postedAnalyticsEvents = mockAPIClient.postedAnalyticsEvents

        XCTAssertTrue(postedAnalyticsEvents.contains("ios.paypal-ba.webswitch.credit.offered.started"))
    }

    func testTokenizePayPalAccount_whenPayPalPaymentCreationSuccessful_performsAppSwitch() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        payPalDriver.tokenizePayPalAccount(with: request) { _,_  -> Void in }

        XCTAssertNotNil(payPalDriver.authenticationSession)
        XCTAssertTrue(payPalDriver.isAuthenticationSessionStarted)

        XCTAssertNotNil(payPalDriver.clientMetadataID)
    }

    // MARK: - handleBrowserSwitchReturn

    func testHandleBrowserSwitchReturn_whenBrowserSwitchCancels_callsBackWithNoResultAndError() {
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

    func testHandleBrowserSwitchReturn_whenBrowserSwitchHasInvalidReturnURL_callsBackWithError() {
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

    func testHandleBrowserSwitchReturn_whenBrowserSwitchSucceeds_tokenizesPayPalCheckout() {
        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        payPalDriver.handleBrowserSwitchReturn(returnURL, paymentType: .checkout) { (_, _) in }

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v1/payment_methods/paypal_accounts")

        let lastPostParameters = mockAPIClient.lastPOSTParameters!
        let paypalAccount = lastPostParameters["paypal_account"] as! [String:Any]
        let options = paypalAccount["options"] as! [String:Any]
        XCTAssertFalse(options["validate"] as! Bool)
    }

    func testHandleBrowserSwitchReturn_whenBrowserSwitchSucceeds_intentShouldExistAsPayPalAccountParameter() {
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

    func testHandleBrowserSwitchReturn_whenBrowserSwitchSucceeds_merchantAccountIdIsSet() {
        let merchantAccountID = "alternate-merchant-account-id"
        payPalDriver.payPalRequest = BTPayPalCheckoutRequest(amount: "1.34")
        payPalDriver.payPalRequest.merchantAccountID = merchantAccountID

        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        payPalDriver.handleBrowserSwitchReturn(returnURL, paymentType: .checkout) { (_, _) in }

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v1/payment_methods/paypal_accounts")
        let lastPostParameters = mockAPIClient.lastPOSTParameters!
        XCTAssertEqual(lastPostParameters["merchant_account_id"] as? String, merchantAccountID)
    }

    func testHandleBrowserSwitchReturn_whenCreditFinancingNotReturned_shouldNotSendCreditAcceptedAnalyticsEvent() {
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

    func testHandleBrowserSwitchReturn_whenCreditFinancingReturned_shouldSendCreditAcceptedAnalyticsEvent() {
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

    // MARK: - Tokenization

    func testHandleBrowserSwitchReturn_whenBrowserSwitchSucceeds_sendsCorrectParametersForTokenization() {
        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        payPalDriver.handleBrowserSwitchReturn(returnURL, paymentType: .vault) { (_, _) in }

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v1/payment_methods/paypal_accounts")
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        guard let paypalAccount = lastPostParameters["paypal_account"] as? [String:Any] else {
            XCTFail()
            return
        }

        let client = paypalAccount["client"] as? [String:String]
        XCTAssertEqual(client?["paypal_sdk_version"], "version")
        XCTAssertEqual(client?["platform"], "iOS")
        XCTAssertEqual(client?["product_name"], "PayPal")

        let response = paypalAccount["response"] as? [String:String]
        XCTAssertEqual(response?["webURL"], "bar://onetouch/v1/success?token=hermes_token")

        XCTAssertEqual(paypalAccount["response_type"] as? String, "web")
    }

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
                ]
            ]
        ]

        mockAPIClient.cannedResponseBody = BTJSON(value: checkoutResponse as [String : AnyObject])

        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        payPalDriver.handleBrowserSwitchReturn(returnURL, paymentType: .checkout) { (tokenizedPayPalAccount, error) in
            XCTAssertEqual(tokenizedPayPalAccount!.nonce, "a-nonce")
            XCTAssertEqual(tokenizedPayPalAccount!.firstName, "Some")
            XCTAssertEqual(tokenizedPayPalAccount!.lastName, "Dude")
            XCTAssertEqual(tokenizedPayPalAccount!.phone, "867-5309")
            XCTAssertEqual(tokenizedPayPalAccount!.email, "hello@world.com")
            XCTAssertEqual(tokenizedPayPalAccount!.payerID, "FAKE-PAYER-ID")

            let billingAddress = tokenizedPayPalAccount!.billingAddress!
            XCTAssertEqual(billingAddress.recipientName, "Bar Foo")
            XCTAssertEqual(billingAddress.streetAddress, "2 Foo Ct")
            XCTAssertEqual(billingAddress.extendedAddress, "Apt Foo")
            XCTAssertEqual(billingAddress.locality, "Barfoo")
            XCTAssertEqual(billingAddress.region, "BF")
            XCTAssertEqual(billingAddress.postalCode, "24")
            XCTAssertEqual(billingAddress.countryCodeAlpha2, "ASU")

            let shippingAddress = tokenizedPayPalAccount!.shippingAddress!
            XCTAssertEqual(shippingAddress.recipientName, "Some Dude")
            XCTAssertEqual(shippingAddress.streetAddress, "3 Foo Ct")
            XCTAssertEqual(shippingAddress.extendedAddress, "Apt 5")
            XCTAssertEqual(shippingAddress.locality, "Dudeville")
            XCTAssertEqual(shippingAddress.region, "CA")
            XCTAssertEqual(shippingAddress.postalCode, "24")
            XCTAssertEqual(shippingAddress.countryCodeAlpha2, "US")
        }
    }

    func testTokenizedPayPalAccount_whenTokenizationResponseDoesNotHaveShippingAddress_returnsAccountAddressAsShippingAddress() {
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
                                "recipientName": "Grace Hopper",
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
                            ]
                        ]
                    ]
                ]
            ]
        ]

        mockAPIClient.cannedResponseBody = BTJSON(value: checkoutResponse as [String : AnyObject])

        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        payPalDriver.handleBrowserSwitchReturn(returnURL, paymentType: .checkout) { (tokenizedPayPalAccount, error) in

            let shippingAddress = tokenizedPayPalAccount!.shippingAddress!
            XCTAssertEqual(shippingAddress.recipientName, "Grace Hopper")
            XCTAssertEqual(shippingAddress.streetAddress, "1 Foo Ct")
            XCTAssertEqual(shippingAddress.extendedAddress, "Apt Bar")
            XCTAssertEqual(shippingAddress.locality, "Fubar")
            XCTAssertEqual(shippingAddress.region, "FU")
            XCTAssertEqual(shippingAddress.postalCode, "42")
            XCTAssertEqual(shippingAddress.countryCodeAlpha2, "USA")
        }
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
        mockAPIClient.cannedResponseBody = BTJSON(value: checkoutResponse as [String : AnyObject])

        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        payPalDriver.handleBrowserSwitchReturn(returnURL, paymentType: .checkout) { (tokenizedPayPalAccount, error) -> Void in
                XCTAssertEqual(tokenizedPayPalAccount!.email, "hello@world.com")
        }
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

    func testAPIClientMetadata_hasIntegrationSetToCustom() {
        let apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")!
        let payPalDriver = BTPayPalDriver(apiClient: apiClient)

        XCTAssertEqual(payPalDriver.apiClient?.metadata.integration, BTClientMetadataIntegrationType.custom)
    }

    func testHandleBrowserSwitchReturn_vault_whenCreditFinancingNotReturned_shouldNotSendCreditAcceptedAnalyticsEvent() {
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
        payPalDriver.payPalRequest = BTPayPalVaultRequest()

        let returnURL = URL(string: "bar://hello/world")!
        payPalDriver.handleBrowserSwitchReturn(returnURL, paymentType: .vault) { (_, _) in }

        XCTAssertFalse(mockAPIClient.postedAnalyticsEvents.contains("ios.paypal-ba.credit.accepted"))
    }

    func testHandleBrowserSwitchReturn_vault_whenCreditFinancingReturned_shouldSendCreditAcceptedAnalyticsEvent() {
        mockAPIClient.cannedResponseBody = BTJSON(
            value: [ "paypalAccounts": [
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

        payPalDriver.payPalRequest = BTPayPalVaultRequest()

        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        payPalDriver.handleBrowserSwitchReturn(returnURL, paymentType: .vault) { (_, _) in }

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("ios.paypal-ba.credit.accepted"))
    }
}
