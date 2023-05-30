import XCTest
@testable import BraintreePayPal
@testable import BraintreeTestShared
@testable import BraintreeCore

class BTPayPalClient_Tests: XCTestCase {
    var mockAPIClient: MockAPIClient!
    var payPalClient: BTPayPalClient!

    override func setUp() {
        super.setUp()

        mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "paypal": ["environment": "offline"]
        ] as [String: Any])
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": ["redirectUrl": "http://fakeURL.com"]
        ])

        payPalClient = BTPayPalClient(apiClient: mockAPIClient)
    }

    func testTokenizePayPalAccount_whenRemoteConfigurationFetchFails_callsBackWithConfigurationError() {
        mockAPIClient.cannedConfigurationResponseBody = nil

        let request = BTPayPalCheckoutRequest(amount: "1")
        let expectation = expectation(description: "Checkout fails with error")

        payPalClient.tokenize(request) { nonce, error in
            guard let error = error as NSError? else { XCTFail(); return }
            XCTAssertNil(nonce)
            XCTAssertEqual(error.domain, BTPayPalError.errorDomain)
            XCTAssertEqual(error.code, BTPayPalError.fetchConfigurationFailed.errorCode)
            XCTAssertEqual(error.localizedDescription, BTPayPalError.fetchConfigurationFailed.errorDescription)
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1)
    }

    func testTokenizePayPalAccount_whenPayPalNotEnabledInConfiguration_callsBackWithError() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": false
        ])

        let request = BTPayPalCheckoutRequest(amount: "1")
        let expectation = expectation(description: "Checkout fails with error")

        payPalClient.tokenize(request) { nonce, error in
            guard let error = error as NSError? else { XCTFail(); return }
            XCTAssertNil(nonce)
            XCTAssertEqual(error.domain, BTPayPalError.errorDomain)
            XCTAssertEqual(error.code, BTPayPalError.disabled.errorCode)
            XCTAssertEqual(error.localizedDescription, "PayPal is not enabled for this merchant. Enable PayPal for this merchant in the Braintree Control Panel.")
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1)
    }

    // MARK: - POST request to Hermes endpoint

    func testTokenizePayPalAccount_checkout_whenRemoteConfigurationFetchSucceeds_postsToCorrectEndpoint() {
        let checkoutRequest = BTPayPalCheckoutRequest(amount: "1")
        checkoutRequest.intent = .sale

        payPalClient.tokenize(checkoutRequest) { _, _ in }

        XCTAssertEqual("v1/paypal_hermes/create_payment_resource", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else { XCTFail(); return }

        XCTAssertEqual(lastPostParameters["intent"] as? String, "sale")
        XCTAssertEqual(lastPostParameters["amount"] as? String, "1")
        XCTAssertEqual(lastPostParameters["return_url"] as? String, "sdk.ios.braintree://onetouch/v1/success")
        XCTAssertEqual(lastPostParameters["cancel_url"] as? String, "sdk.ios.braintree://onetouch/v1/cancel")
    }

    func testTokenizePayPalAccount_vault_whenRemoteConfigurationFetchSucceeds_postsToCorrectEndpoint() {
        let vaultRequest = BTPayPalVaultRequest()
        vaultRequest.billingAgreementDescription = "description"
        
        payPalClient.tokenize(vaultRequest) { _, _ in }

        XCTAssertEqual("v1/paypal_hermes/setup_billing_agreement", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else { XCTFail(); return }

        XCTAssertEqual(lastPostParameters["description"] as? String, "description")
        XCTAssertEqual(lastPostParameters["return_url"] as? String, "sdk.ios.braintree://onetouch/v1/success")
        XCTAssertEqual(lastPostParameters["cancel_url"] as? String, "sdk.ios.braintree://onetouch/v1/cancel")
    }

    func testTokenizePayPalAccount_whenPostRequestContainsError_callsBackWithError() {
        let stubJSONResponse = BTJSON(
            value: [
                "paymentResource" : [
                    "errorDetails" : [
                        "issue": "A fake error issue"
                    ]
                ]
            ]
        )

        let stubError = NSError(
            domain: BTPayPalError.errorDomain,
            code: BTPayPalError.httpPostRequestError([:]).errorCode,
            userInfo: [
                BTCoreConstants.jsonResponseBodyKey: stubJSONResponse
            ]
        )

        mockAPIClient.cannedResponseError = stubError

        let dummyRequest = BTPayPalCheckoutRequest(amount: "1")
        let expectation = expectation(description: "Checkout fails with error")
        payPalClient.tokenize(dummyRequest) { _, error in
            guard let error = error as NSError? else { XCTFail(); return }
            XCTAssertNotNil(error)
            XCTAssertEqual(error.domain, BTPayPalError.errorDomain)
            XCTAssertEqual(error.code, BTPayPalError.httpPostRequestError([:]).errorCode)
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
        payPalClient.tokenize(request) { _, _ in }

        XCTAssertEqual("https://www.paypal.com/checkout?EC-Token=EC-Random-Value", payPalClient.approvalURL?.absoluteString)
    }

    func testTokenizePayPalAccount_vault_whenUserActionIsNotSet_approvalUrlIsNotModified() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "agreementSetup": [
                "approvalUrl": "https://checkout.paypal.com/one-touch-login-sandbox"
            ]
        ])

        let request = BTPayPalVaultRequest()
        payPalClient.tokenize(request) { _, _ in }

        XCTAssertEqual("https://checkout.paypal.com/one-touch-login-sandbox", payPalClient.approvalURL?.absoluteString)
    }

    func testTokenizePayPalAccount_whenUserActionIsSetToDefault_approvalUrlIsNotModified() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": [
                "redirectUrl": "https://www.paypal.com/checkout?EC-Token=EC-Random-Value"
            ]
        ])

        let request = BTPayPalCheckoutRequest(amount: "1")
        request.userAction = BTPayPalRequestUserAction.none

        payPalClient.tokenize(request) { _, _ in }

        XCTAssertEqual("https://www.paypal.com/checkout?EC-Token=EC-Random-Value", payPalClient.approvalURL?.absoluteString)
    }

    func testTokenizePayPalAccount_whenUserActionIsSetToCommit_approvalUrlIsModified() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": [
                "redirectUrl": "https://www.paypal.com/checkout?EC-Token=EC-Random-Value"
            ]
        ])

        let request = BTPayPalCheckoutRequest(amount: "1")
        request.userAction = BTPayPalRequestUserAction.payNow

        payPalClient.tokenize(request) { _, _ in }

        XCTAssertEqual("https://www.paypal.com/checkout?EC-Token=EC-Random-Value&useraction=commit", payPalClient.approvalURL?.absoluteString)
    }

    func testTokenizePayPalAccount_whenUserActionIsSetToCommit_andNoQueryParamsArePresent_approvalUrlIsModified() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": [
                "redirectUrl": "https://www.paypal.com/checkout"
            ]
        ])

        let request = BTPayPalCheckoutRequest(amount: "1")
        request.userAction = BTPayPalRequestUserAction.payNow

        payPalClient.tokenize(request) { _, _ in }

        XCTAssertEqual("https://www.paypal.com/checkout?useraction=commit", payPalClient.approvalURL?.absoluteString)
    }

    func testTokenizePayPalAccount_whenApprovalUrlIsNotHTTP_returnsError() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": [
                "redirectUrl": "file://some-url.com"
            ]
        ])

        let request = BTPayPalCheckoutRequest(amount: "1")
        let expectation = expectation(description: "Returns error")

        payPalClient.tokenize(request) { nonce, error in
            XCTAssertNil(nonce)
            XCTAssertEqual((error! as NSError).domain, BTPayPalError.errorDomain)
            XCTAssertEqual((error! as NSError).code, BTPayPalError.asWebAuthenticationSessionURLInvalid("").errorCode)
            XCTAssertEqual((error! as NSError).localizedDescription, "Attempted to open an invalid URL in ASWebAuthenticationSession: file://. Try again or contact Braintree Support.")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testTokenizePayPalAccount_whenApprovalUrlIsInvalid_returnsError() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": [
                "redirectUrl": ""
            ]
        ])

        let request = BTPayPalCheckoutRequest(amount: "1")
        let expectation = expectation(description: "Returns error")

        payPalClient.tokenize(request) { nonce, error in
            guard let error = error as NSError? else { XCTFail(); return }
            XCTAssertNil(nonce)
            XCTAssertEqual(error.domain, BTPayPalError.errorDomain)
            XCTAssertEqual(error.code, BTPayPalError.invalidURL.errorCode)
            XCTAssertEqual(error.localizedDescription, BTPayPalError.invalidURL.errorDescription)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }


    // MARK: - Browser switch

    func testTokenizePayPalAccount_whenPayPalPayLaterOffered_performsSwitchCorrectly() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        request.currencyCode = "GBP"
        request.offerPayLater = true

        payPalClient.tokenize(request) { _, _ in }

        XCTAssertNotNil(payPalClient.authenticationSession)
        XCTAssertTrue(payPalClient.isAuthenticationSessionStarted)

        // Ensure the payment resource had the correct parameters
        XCTAssertEqual("v1/paypal_hermes/create_payment_resource", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        XCTAssertEqual(lastPostParameters["offer_pay_later"] as? Bool, true)

        // Make sure analytics event was sent when switch occurred
        let postedAnalyticsEvents = mockAPIClient.postedAnalyticsEvents

        XCTAssertTrue(postedAnalyticsEvents.contains(BTPayPalAnalytics.browserPresentationSucceeded))
    }

    func testTokenizePayPalAccount_whenPayPalCreditOffered_performsSwitchCorrectly() {
        let request = BTPayPalVaultRequest()
        request.offerCredit = true

        payPalClient.tokenize(request) { _, _ in }

        XCTAssertNotNil(payPalClient.authenticationSession)
        XCTAssertTrue(payPalClient.isAuthenticationSessionStarted)

        // Ensure the payment resource had the correct parameters
        XCTAssertEqual("v1/paypal_hermes/setup_billing_agreement", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        XCTAssertEqual(lastPostParameters["offer_paypal_credit"] as? Bool, true)

        // Make sure analytics event was sent when switch occurred
        let postedAnalyticsEvents = mockAPIClient.postedAnalyticsEvents

        XCTAssertTrue(postedAnalyticsEvents.contains(BTPayPalAnalytics.browserPresentationSucceeded))
    }

    func testTokenizePayPalAccount_whenPayPalPaymentCreationSuccessful_performsAppSwitch() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        payPalClient.tokenize(request) { _, _ in }

        XCTAssertNotNil(payPalClient.authenticationSession)
        XCTAssertTrue(payPalClient.isAuthenticationSessionStarted)

        XCTAssertNotNil(payPalClient.clientMetadataID)
    }

    // MARK: - handleBrowserSwitchReturn

    func testHandleBrowserSwitchReturn_whenBrowserSwitchCancels_callsBackWithNoResultAndError() {
        let returnURL = URL(string: "bar://onetouch/v1/cancel?token=hermes_token")!

        let expectation = expectation(description: "completion block called")

        payPalClient.handleBrowserSwitchReturn(returnURL, paymentType: .checkout) { nonce, error in
            guard let error = error as NSError? else { XCTFail(); return }
            XCTAssertNil(nonce)
            XCTAssertEqual(error.domain, BTPayPalError.errorDomain)
            XCTAssertEqual(error.code, BTPayPalError.canceled.errorCode)
            XCTAssertEqual(error.localizedDescription, BTPayPalError.canceled.errorDescription)
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1)
    }

    func testHandleBrowserSwitchReturn_whenBrowserSwitchHasInvalidReturnURL_callsBackWithError() {
        let returnURL = URL(string: "bar://onetouch/v1/invalid")!

        let continuationExpectation = expectation(description: "Continuation called")

        payPalClient.handleBrowserSwitchReturn(returnURL, paymentType: .checkout) { nonce, error in
            guard let error = error as NSError? else { XCTFail(); return }
            XCTAssertNil(nonce)
            XCTAssertNotNil(error)
            XCTAssertEqual(error.domain, BTPayPalError.errorDomain)
            XCTAssertEqual(error.code, BTPayPalError.invalidURLAction.errorCode)
            XCTAssertEqual(error.localizedDescription, BTPayPalError.invalidURLAction.errorDescription)
            continuationExpectation.fulfill()
        }

        self.waitForExpectations(timeout: 1)
    }

    func testHandleBrowserSwitchReturn_whenBrowserSwitchSucceeds_tokenizesPayPalCheckout() {
        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        payPalClient.handleBrowserSwitchReturn(returnURL, paymentType: .checkout) { _, _ in }

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v1/payment_methods/paypal_accounts")

        let lastPostParameters = mockAPIClient.lastPOSTParameters!
        let paypalAccount = lastPostParameters["paypal_account"] as! [String:Any]
        let options = paypalAccount["options"] as! [String:Any]
        XCTAssertFalse(options["validate"] as! Bool)
    }

    func testHandleBrowserSwitchReturn_whenBrowserSwitchSucceeds_intentShouldExistAsPayPalAccountParameter() {
        let payPalRequest = BTPayPalCheckoutRequest(amount: "1.34")
        payPalRequest.intent = .sale
        payPalClient.clientMetadataID = "fake-client-metadata-id"
        payPalClient.payPalRequest = payPalRequest

        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        payPalClient.handleBrowserSwitchReturn(returnURL, paymentType: .checkout) { _, _ in }

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v1/payment_methods/paypal_accounts")

        let lastPostParameters = mockAPIClient.lastPOSTParameters!
        let paypalAccount = lastPostParameters["paypal_account"] as! [String:Any]
        XCTAssertEqual(paypalAccount["intent"] as? String, "sale")

        let options = paypalAccount["options"] as! [String:Any]
        XCTAssertFalse(options["validate"] as! Bool)
    }

    func testHandleBrowserSwitchReturn_whenBrowserSwitchSucceeds_merchantAccountIdIsSet() {
        let merchantAccountID = "alternate-merchant-account-id"
        payPalClient.payPalRequest = BTPayPalCheckoutRequest(amount: "1.34")
        payPalClient.payPalRequest?.merchantAccountID = merchantAccountID

        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        payPalClient.handleBrowserSwitchReturn(returnURL, paymentType: .checkout) { _, _ in }

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
                    ] as [String: Any]
                ]
        ])
        payPalClient.payPalRequest = BTPayPalCheckoutRequest(amount: "1.34")

        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        payPalClient.handleBrowserSwitchReturn(returnURL, paymentType: .checkout) { _, _ in }

        XCTAssertFalse(mockAPIClient.postedAnalyticsEvents.contains("ios.paypal-single-payment.credit.accepted"))
    }

    func testHandleBrowserSwitchReturn_whenNonceIsNotCreated_returnsError() {
        mockAPIClient.cannedResponseBody = BTJSON(value: ["not-a-paypalAccount"])
        payPalClient.payPalRequest = BTPayPalCheckoutRequest(amount: "1.34")

        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        let expectation = expectation(description: "Returns an error")
        payPalClient.handleBrowserSwitchReturn(returnURL, paymentType: .checkout) { _, error in
            guard let error = error as NSError? else { XCTFail(); return }
            XCTAssertNotNil(error)
            XCTAssertEqual(error.domain, BTPayPalError.errorDomain)
            XCTAssertEqual(error.code, BTPayPalError.failedToCreateNonce.errorCode)
            XCTAssertEqual(error.localizedDescription, BTPayPalError.failedToCreateNonce.localizedDescription)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    // MARK: - Tokenization

    func testHandleBrowserSwitchReturn_whenBrowserSwitchSucceeds_sendsCorrectParametersForTokenization() {
        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        payPalClient.handleBrowserSwitchReturn(returnURL, paymentType: .vault) { _, _ in }

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
                        ] as [String: Any]
                    ] as [String: Any]
                ] as [String: Any]
            ]
        ]

        mockAPIClient.cannedResponseBody = BTJSON(value: checkoutResponse as [String : AnyObject])

        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        payPalClient.handleBrowserSwitchReturn(returnURL, paymentType: .checkout) { (tokenizedPayPalAccount, error) in
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
                        ] as [String: Any]
                    ] as [String: Any]
                ] as [String: Any]
            ]
        ]

        mockAPIClient.cannedResponseBody = BTJSON(value: checkoutResponse as [String : AnyObject])

        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        payPalClient.handleBrowserSwitchReturn(returnURL, paymentType: .checkout) { (tokenizedPayPalAccount, error) in

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
                        "payerInfo": ["email": "hello@world.com"]
                    ] as [String: Any],
                ] as [String: Any]
            ]
        ]
        mockAPIClient.cannedResponseBody = BTJSON(value: checkoutResponse as [String : AnyObject])

        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        payPalClient.handleBrowserSwitchReturn(returnURL, paymentType: .checkout) { tokenizedPayPalAccount, error in
                XCTAssertEqual(tokenizedPayPalAccount!.email, "hello@world.com")
        }
    }

    // MARK: - _meta parameter

    func testMetadata_whenCheckoutBrowserSwitchIsSuccessful_isPOSTedToServer() {
        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        payPalClient.handleBrowserSwitchReturn(returnURL, paymentType: .checkout) { _, _ in }

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
        let payPalClient = BTPayPalClient(apiClient: apiClient)

        XCTAssertEqual(payPalClient.apiClient.metadata.integration, BTClientMetadataIntegration.custom)
    }

    func testHandleBrowserSwitchReturn_vault_whenCreditFinancingNotReturned_shouldNotSendCreditAcceptedAnalyticsEvent() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paypalAccounts":
                [
                    [
                        "description": "jane.doe@example.com",
                        "details": [
                            "email": "jane.doe@example.com",
                        ],
                        "nonce": "a-nonce",
                        "type": "PayPalAccount",
                    ] as [String: Any]
                ]
        ])
        payPalClient.payPalRequest = BTPayPalVaultRequest()

        let returnURL = URL(string: "bar://hello/world")!
        payPalClient.handleBrowserSwitchReturn(returnURL, paymentType: .vault) { _, _ in }

        XCTAssertFalse(mockAPIClient.postedAnalyticsEvents.contains("ios.paypal-ba.credit.accepted"))
    }
}
