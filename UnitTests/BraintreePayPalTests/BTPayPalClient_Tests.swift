import XCTest
@testable import BraintreePayPal
@testable import BraintreeTestShared
@testable import BraintreeCore

class BTPayPalClient_Tests: XCTestCase {
    var mockAPIClient: MockAPIClient!
    var payPalClient: BTPayPalClient!
    var mockWebAuthenticationSession: MockWebAuthenticationSession!

    override func setUp() {
        super.setUp()

        mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "paypal": ["environment": "offline"],
            "merchantId": "testMerchantId"
        ] as [String: Any])
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": ["redirectUrl": "http://fakeURL.com"]
        ])
        payPalClient = BTPayPalClient(apiClient: mockAPIClient, universalLink: URL(string: "https://www.paypal.com")!, fallbackURLScheme: "paypal")
        mockWebAuthenticationSession = MockWebAuthenticationSession()
        payPalClient.webAuthenticationSession = mockWebAuthenticationSession
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
            XCTAssertTrue(error.localizedDescription.contains("A fake error issue"), "error description should contain the fake error issue")
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

    func testTokenizePayPalAccount_whenAllApprovalURLsInvalid_returnsError() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "agreementSetup": [
                "approvalUrl": "",
                "paypalAppApprovalUrl": ""
            ]
        ])

        let request = BTPayPalCheckoutRequest(amount: "1")
        let expectation = expectation(description: "Returns error")

        payPalClient.tokenize(request) { nonce, error in
            guard let error = error as NSError? else { XCTFail(); return }
            XCTAssertNil(nonce)
            XCTAssertEqual(error.domain, BTPayPalError.errorDomain)
            XCTAssertEqual(error.code, BTPayPalError.invalidURL("").errorCode)
            XCTAssertEqual(error.localizedDescription, "An error occurred with retrieving a PayPal URL: Missing approval URL in gateway response.")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testTokenize_whenApprovalURLContainsContextID_sendsContextIDInAnalytics() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": [
                "redirectUrl": "https://www.paypal.com/checkout?token=EC-Random-Value"
            ]
        ])

        mockWebAuthenticationSession.cannedResponseURL = URL(string: "https://www.paypal.com/checkout/success?token=EC-Random-Value")

        let request = BTPayPalCheckoutRequest(amount: "1")
        payPalClient.tokenize(request) { _, _ in }

        XCTAssertEqual(mockAPIClient.postedContextID, "EC-Random-Value")
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("paypal:tokenize:handle-return:started"))
    }
    
    func testTokenize_whenPayPalAppApprovalURLContainsContextID_sendsContextIDAndAppSwitchInAnalytics() {
        let fakeApplication = FakeApplication()
        payPalClient.application = fakeApplication
        payPalClient.webAuthenticationSession = MockWebAuthenticationSession()
        let token = "BA-Random-Value"
        
        let vaultRequest = BTPayPalVaultRequest(
            userAuthenticationEmail: "fake@gmail.com",
            enablePayPalAppSwitch: true
        )

        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "agreementSetup": [
                "paypalAppApprovalUrl": "https://www.paypal.com?ba_token=\(token)"
            ]
        ])

        payPalClient.tokenize(vaultRequest) { _, _ in }

        let returnURL = URL(string: "https://www.merchant-app.com/merchant-path/success?ba_token=\(token)&switch_initiated_time=1234567890")!
        payPalClient.handleReturnURL(returnURL)

        XCTAssertEqual(mockAPIClient.postedContextID, "BA-Random-Value")
        XCTAssertEqual(mockAPIClient.postedDidEnablePayPalAppSwitch, true)
        XCTAssertEqual(mockAPIClient.postedDidPayPalServerAttemptAppSwitch, true)
        XCTAssertEqual(payPalClient.clientMetadataIDs["BA-Random-Value"], "BA-Random-Value")
    }

    func testTokenize_whenApprovalURLDoesNotContainContextID_doesNotSendContextIDInAnalytics() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": [
                "redirectUrl": "https://www.paypal.com/checkout?token="
            ]
        ])

        let request = BTPayPalCheckoutRequest(amount: "1")
        payPalClient.tokenize(request) { _, _ in }

        XCTAssertNil(mockAPIClient.postedContextID)
    }

    func testTokenize_whenApprovalURLContainsECAndBAToken_sendsBATokenAsContextIDAndAppSwitchInAnalytics() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": [
                "redirectUrl": "https://www.paypal.com/checkout?token=EC-Random-Value&ba_token=BA-Random-Value"
            ]
        ])

        mockWebAuthenticationSession.cannedResponseURL = URL(string: "https://www.paypal.com/checkout/success?ba_token=BA-Random-Value")

        let request = BTPayPalCheckoutRequest(amount: "1")
        payPalClient.tokenize(request) { _, _ in }

        XCTAssertEqual(mockAPIClient.postedContextID, "BA-Random-Value")
        XCTAssertEqual(mockAPIClient.postedDidEnablePayPalAppSwitch, false)
        XCTAssertEqual(mockAPIClient.postedDidPayPalServerAttemptAppSwitch, false)
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("paypal:tokenize:handle-return:started"))
    }

    func testTokenize_whenApprovalUrlContainsBAToken_sendsBATokenAsContextIDAndAppSwitchInAnalytics() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "agreementSetup": [
                "approvalUrl": "https://www.paypal.com/agreements/approve?ba_token=A_FAKE_BA_TOKEN"
            ]
        ])

        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        mockWebAuthenticationSession.cannedResponseURL = URL(string: "sdk.ios.braintree://onetouch/v1/success?ba_token=A_FAKE_BA_TOKEN")
        payPalClient.webAuthenticationSession = mockWebAuthenticationSession

        let request = BTPayPalVaultRequest()
        payPalClient.tokenize(request) { _, _ in }

        XCTAssertEqual(mockAPIClient.postedContextID, "A_FAKE_BA_TOKEN")
        XCTAssertEqual(mockAPIClient.postedDidEnablePayPalAppSwitch, false)
        XCTAssertEqual(mockAPIClient.postedDidPayPalServerAttemptAppSwitch, false)
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("paypal:tokenize:handle-return:started"))
    }
    
    func testTokenize_whenApprovalURLContainsExperiment_doesNotRenderWASPopup() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": [
                "redirectUrl": "https://www.paypal.com/checkout?token=ec-random-value&experiment=InAppBrowserNoPopup"
            ]
        ])
        
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        mockWebAuthenticationSession.cannedResponseURL = URL(string: "sdk.ios.braintree://onetouch/v1/success?token=ec-random-value")
        payPalClient.webAuthenticationSession = mockWebAuthenticationSession
        
        let request = BTPayPalCheckoutRequest(amount: "10.00")
        payPalClient.tokenize(request) { _, _ in }
        
        if let disableWASPopup = mockWebAuthenticationSession.prefersEphemeralWebBrowserSession {
            XCTAssertTrue(disableWASPopup)
        }
        XCTAssertEqual(mockAPIClient.postedContextID, "ec-random-value")
        XCTAssertEqual(mockAPIClient.postedDidEnablePayPalAppSwitch, false)
        XCTAssertEqual(mockAPIClient.postedDidPayPalServerAttemptAppSwitch, false)
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("paypal:tokenize:handle-return:started"))
        XCTAssertFalse(mockAPIClient.postedAnalyticsEvents.contains("paypal:tokenize:browser-login:alert-canceled"))
    }
    
    func testTokenize_whenApprovalURLContainsWASExperimentANDUserCancelsOutOfFlow_sendsCorrectAnalyticEvents() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": [
                "redirectUrl": "https://www.paypal.com/checkout?token=ec-random-value&experiment=InAppBrowserNoPopup"
            ]
        ])
        
        let mockWebAuthenticationSession = MockWebAuthenticationSession()
        mockWebAuthenticationSession.cannedResponseURL = URL(string: "sdk.ios.braintree://onetouch/v1/cancel?token=ec-random-value")
        payPalClient.webAuthenticationSession = mockWebAuthenticationSession
        
        let request = BTPayPalCheckoutRequest(amount: "10.00")
        payPalClient.tokenize(request) { _, _ in }
        
        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.first!, BTPayPalAnalytics.tokenizeStarted)
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTPayPalAnalytics.browserPresentationSucceeded))
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTPayPalAnalytics.handleReturnStarted))
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTPayPalAnalytics.browserLoginCanceled))
        XCTAssertFalse(mockAPIClient.postedAnalyticsEvents.contains(BTPayPalAnalytics.browserLoginAlertCanceled))
    }
    
    func testTokenize_whenApprovalURLIsWebBrowserRedirectType_sendsBrowserPresentationStartedEvent() {
        let approvalURL = "https://www.paypal.com/agreements/approve?ba_token=A_FAKE_BA_TOKEN"
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "agreementSetup": [
                "approvalUrl": "https://www.paypal.com/agreements/approve?ba_token=A_FAKE_BA_TOKEN"
            ]
        ])
        
        let request = BTPayPalCheckoutRequest(amount: "10.00")
        let returnURL = URL(string: "sdk.ios.braintree://onetouch/v1/success?ba_token=A_FAKE_BA_TOKEN")
        mockWebAuthenticationSession.cannedResponseURL = URL(string: "sdk.ios.braintree://onetouch/v1/success?ba_token=A_FAKE_BA_TOKEN")
        payPalClient.tokenize(request) { _, _ in }
        
        XCTAssertEqual(mockAPIClient.postedContextID, "A_FAKE_BA_TOKEN")
        XCTAssertEqual(mockAPIClient.postedDidEnablePayPalAppSwitch, false)
        XCTAssertEqual(mockAPIClient.postedDidPayPalServerAttemptAppSwitch, false)
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("paypal:tokenize:browser-presentation:started"))
        XCTAssertEqual(mockAPIClient.postedAppSwitchURL["paypal:tokenize:browser-presentation:started"], approvalURL)
        XCTAssertEqual(mockAPIClient.postedAppSwitchURL["paypal:tokenize:handle-return:started"], returnURL?.absoluteString)
    }

    // MARK: - Browser switch

    func testTokenizePayPalAccount_whenPayPalPayLaterOffered_performsSwitchCorrectly() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        request.currencyCode = "GBP"
        request.offerPayLater = true

        payPalClient.tokenize(request) { _, _ in }

        XCTAssertNotNil(payPalClient.webAuthenticationSession)

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

        XCTAssertNotNil(payPalClient.webAuthenticationSession)

        // Ensure the payment resource had the correct parameters
        XCTAssertEqual("v1/paypal_hermes/setup_billing_agreement", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        XCTAssertEqual(lastPostParameters["offer_paypal_credit"] as? Bool, true)

        // Make sure analytics event was sent when switch occurred
        let postedAnalyticsEvents = mockAPIClient.postedAnalyticsEvents
        let postedAppSwitchURLs = mockAPIClient.postedAppSwitchURL
        
        XCTAssertTrue(postedAnalyticsEvents.contains(BTPayPalAnalytics.browserPresentationSucceeded))
        XCTAssertEqual(postedAppSwitchURLs[BTPayPalAnalytics.browserPresentationSucceeded], "http://fakeURL.com")
    }
    
    func testTokenize_whenSessionIsDuplicated_sendsDuplicateRequestAnalyticsEvent() {
        let request = BTPayPalVaultRequest()
        mockWebAuthenticationSession.cannedSessionDidDuplicate = true
        
        payPalClient.tokenize(request) { _, _ in }
        
        let postedAnalyticsEvents = mockAPIClient.postedAnalyticsEvents
        let postedAppSwitchURLs = mockAPIClient.postedAppSwitchURL
        
        XCTAssertTrue(postedAnalyticsEvents.contains(BTPayPalAnalytics.tokenizeDuplicateRequest))
        XCTAssertEqual(postedAppSwitchURLs[BTPayPalAnalytics.tokenizeDuplicateRequest], "http://fakeURL.com")
    }

    // MARK: - handleBrowserSwitchReturn

    func testHandleBrowserSwitchReturn_whenBrowserSwitchCancels_callsBackWithNoResultAndError() {
        let returnURL = URL(string: "bar://onetouch/v1/cancel?token=hermes_token")!

        let expectation = expectation(description: "completion block called")

        payPalClient.handleReturn(returnURL, paymentType: .checkout) { nonce, error in
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

        payPalClient.handleReturn(returnURL, paymentType: .checkout) { nonce, error in
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
        payPalClient.handleReturn(returnURL, paymentType: .checkout) { _, _ in }

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v1/payment_methods/paypal_accounts")

        let lastPostParameters = mockAPIClient.lastPOSTParameters!
        let paypalAccount = lastPostParameters["paypal_account"] as! [String:Any]
        let options = paypalAccount["options"] as! [String:Any]
        XCTAssertFalse(options["validate"] as! Bool)
    }

    func testHandleBrowserSwitchReturn_whenBrowserSwitchSucceeds_intentShouldExistAsPayPalAccountParameter() {
        let payPalRequest = BTPayPalCheckoutRequest(amount: "1.34")
        payPalRequest.intent = .sale
        let token = "hermes_token"
        payPalClient.clientMetadataIDs = [token: "fake-client-metadata-id"]
        payPalClient.payPalRequest = payPalRequest

        let returnURL = URL(string: "bar://onetouch/v1/success?token=\(token)")!
        payPalClient.handleReturn(returnURL, paymentType: payPalRequest.paymentType) { _, _ in }

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v1/payment_methods/paypal_accounts")

        let lastPostParameters = mockAPIClient.lastPOSTParameters!
        let paypalAccount = lastPostParameters["paypal_account"] as! [String: Any]
        XCTAssertEqual(paypalAccount["intent"] as? String, "sale")

        let options = paypalAccount["options"] as! [String: Any]
        XCTAssertFalse(options["validate"] as! Bool)
    }

    func testHandleBrowserSwitchReturn_whenBrowserSwitchSucceeds_intentShouldBeNilForVaultRequests() {
        let payPalRequest = BTPayPalVaultRequest()
        let returnURL = URL(string: "bar://onetouch/v1/success?ec-token=ec_token")!
        payPalClient.handleReturn(returnURL, paymentType: payPalRequest.paymentType) { _, _ in }

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v1/payment_methods/paypal_accounts")

        let lastPostParameters = mockAPIClient.lastPOSTParameters!
        let paypalAccount = lastPostParameters["paypal_account"] as! [String: Any]
        XCTAssertNil(paypalAccount["intent"])
    }

    func testHandleBrowserSwitchReturn_whenBrowserSwitchSucceeds_merchantAccountIdIsSet() {
        let merchantAccountID = "alternate-merchant-account-id"
        payPalClient.payPalRequest = BTPayPalCheckoutRequest(amount: "1.34")
        payPalClient.payPalRequest?.merchantAccountID = merchantAccountID

        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        payPalClient.handleReturn(returnURL, paymentType: .checkout) { _, _ in }

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
        payPalClient.handleReturn(returnURL, paymentType: .checkout) { _, _ in }

        XCTAssertFalse(mockAPIClient.postedAnalyticsEvents.contains("ios.paypal-single-payment.credit.accepted"))
    }

    func testHandleBrowserSwitchReturn_whenNonceIsNotCreated_returnsError() {
        mockAPIClient.cannedResponseBody = BTJSON(value: ["not-a-paypalAccount"])
        payPalClient.payPalRequest = BTPayPalCheckoutRequest(amount: "1.34")

        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        let expectation = expectation(description: "Returns an error")
        payPalClient.handleReturn(returnURL, paymentType: .checkout) { _, error in
            guard let error = error as NSError? else { XCTFail(); return }
            XCTAssertNotNil(error)
            XCTAssertEqual(error.domain, BTPayPalError.errorDomain)
            XCTAssertEqual(error.code, BTPayPalError.failedToCreateNonce.errorCode)
            XCTAssertEqual(error.localizedDescription, BTPayPalError.failedToCreateNonce.localizedDescription)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
    }

    func testHandleBrowserSwitchReturn_whenBrowserSwitchSucceeds_parametersAreConstructedAsExpected() {
        let merchantAccountID = "alternate-merchant-account-id"
        payPalClient.payPalRequest = BTPayPalCheckoutRequest(amount: "1.34")
        payPalClient.payPalRequest?.merchantAccountID = merchantAccountID
        let token = "hermes_token"
        payPalClient.clientMetadataIDs = [token: "a-fake-cmid"]

        let returnURL = URL(string: "bar://onetouch/v1/success?token=\(token)")!
        payPalClient.handleReturn(returnURL, paymentType: .checkout) { _, _ in }

        let lastPostParameters = mockAPIClient.lastPOSTParameters!
        XCTAssertEqual(lastPostParameters["merchant_account_id"] as? String, merchantAccountID)

        let account = lastPostParameters["paypal_account"] as? [String: Any]
        XCTAssertEqual(account?["response_type"] as? String, "web")
        XCTAssertEqual(account?["correlation_id"] as? String, "a-fake-cmid")
        XCTAssertEqual(account?["options"] as? [String: Bool], ["validate": false])
        XCTAssertEqual(account?["intent"] as? String, (payPalClient.payPalRequest as? BTPayPalCheckoutRequest)?.intent.stringValue)

        let client = account?["client"] as? [String: String]
        XCTAssertEqual(client?["platform"], "iOS")
        XCTAssertEqual(client?["product_name"], "PayPal")
        XCTAssertEqual(client?["paypal_sdk_version"], "version")

        let response = account?["response"] as? [String: String]
        XCTAssertEqual(response?["webURL"], "bar://onetouch/v1/success?token=hermes_token")
    }
    
    func testHandleBrowserSwitchReturn_whenSuccessURL_sendsAnalytics() {
        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        let expectation = expectation(description: "completion block called")

        payPalClient.handleReturn(returnURL, paymentType: .checkout) { _, _ in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v1/payment_methods/paypal_accounts")
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTPayPalAnalytics.handleReturnStarted))
        XCTAssertEqual(mockAPIClient.postedAppSwitchURL[BTPayPalAnalytics.handleReturnStarted], returnURL.absoluteString)
    }

    // MARK: - Tokenization

    func testHandleBrowserSwitchReturn_whenBrowserSwitchSucceeds_sendsCorrectParametersForTokenization() {
        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        payPalClient.handleReturn(returnURL, paymentType: .vault) { _, _ in }

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
        payPalClient.handleReturn(returnURL, paymentType: .checkout) { (tokenizedPayPalAccount, error) in
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
        payPalClient.handleReturn(returnURL, paymentType: .checkout) { (tokenizedPayPalAccount, error) in

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
        payPalClient.handleReturn(returnURL, paymentType: .checkout) { tokenizedPayPalAccount, error in
                XCTAssertEqual(tokenizedPayPalAccount!.email, "hello@world.com")
        }
    }

    // MARK: - _meta parameter

    func testMetadata_whenCheckoutBrowserSwitchIsSuccessful_isPOSTedToServer() {
        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        payPalClient.handleReturn(returnURL, paymentType: .checkout) { _, _ in }

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v1/payment_methods/paypal_accounts")
        let lastPostParameters = mockAPIClient.lastPOSTParameters!
        let metaParameters = lastPostParameters["_meta"] as! [String:Any]
        XCTAssertEqual(metaParameters["source"] as? String, "paypal-browser")
        XCTAssertEqual(metaParameters["integration"] as? String, "custom")
        XCTAssertEqual(metaParameters["sessionId"] as? String, mockAPIClient.metadata.sessionID)
    }

    // MARK: - App Switch - canHandleReturnURL

    func testCanHandleReturnURL_whenHostIsURLScheme_returnsFalse() {
        let url = URL(string: "fake-scheme://success")!
        XCTAssertFalse(BTPayPalClient.canHandleReturnURL(url))
    }

    func testCanHandleReturnURL_whenPathIsInvalid_returnsFalse() {
        let url = URL(string: "https://mycoolwebsite.com/junkpath")!
        XCTAssertFalse(BTPayPalClient.canHandleReturnURL(url))
    }

    func testCanHandleReturnURL_whenSchemeIsHTTP_returnsFalse() {
        let url = URL(string: "http://mycoolwebsite.com/success")!
        XCTAssertFalse(BTPayPalClient.canHandleReturnURL(url))
    }

    func testCanHandleReturnURL_whenPathIsValidSuccess_returnsTrue() {
        let url = URL(string: "https://mycoolwebsite.com/braintree-payments/braintreeAppSwitchPayPal/success")!
        XCTAssertTrue(BTPayPalClient.canHandleReturnURL(url))
    }

    func testCanHandleReturnURL_whenPathIsValidCancel_returnsTrue() {
        let url = URL(string: "https://mycoolwebsite.com/braintree-payments/braintreeAppSwitchPayPal/cancel")!
        XCTAssertTrue(BTPayPalClient.canHandleReturnURL(url))
    }

    func testCanHandleReturnURL_whenPathIsValidWithQueryParameters_returnsTrue() {
        let url = URL(string: "https://mycoolwebsite.com/braintree-payments/braintreeAppSwitchPayPal/success?token=112233")!
        XCTAssertTrue(BTPayPalClient.canHandleReturnURL(url))
    }

    func testHandleReturnURL_whenURLIsValid_setsBTPayPalClientToNil() {
        BTPayPalClient.handleReturnURL(URL(string: "https://mycoolwebsite.com/braintree-payments/success")!)
        XCTAssertNil(BTPayPalClient.payPalClient)
    }
    
    func testHandleReturnURL_withFallBack() {
        let url = URL(string: "paypal://braintree-payments/braintreeAppSwitchPayPal/success")!
        BTPayPalClient.payPalClient = self.payPalClient
        XCTAssertTrue(BTPayPalClient.canHandleReturnURL(url))
    }
    
    func testHandleReturnURL_withFallBack_noBraintreePath() {
        let url = URL(string: "paypal://braintree-payments/success")!
        BTPayPalClient.payPalClient = self.payPalClient
        XCTAssertFalse(BTPayPalClient.canHandleReturnURL(url))
    }
    
    func testHandleReturnURL_withFallBack_noSuccess() {
        let url = URL(string: "paypal://braintree-payment/braintreeAppSwitchPayPal")!
        BTPayPalClient.payPalClient = self.payPalClient
        XCTAssertFalse(BTPayPalClient.canHandleReturnURL(url))
    }

    func testHandleReturnURL_whenFallBack_wrongScheme() {
        let url = URL(string: "palpay://")!
        BTPayPalClient.payPalClient = self.payPalClient
        XCTAssertFalse(BTPayPalClient.canHandleReturnURL(url))
    }
    
    // MARK: - App Switch - Tokenize

    func testTokenizeVaultAccount_whenPayPalAppApprovalURLPresent_attemptsAppSwitchWithParameters() async {
        let fakeApplication = FakeApplication()
        payPalClient.application = fakeApplication

        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "agreementSetup": [
                "paypalAppApprovalUrl": "https://www.some-url.com/some-path?ba_token=value1"
            ]
        ])
        
        let vaultRequest = BTPayPalVaultRequest(
            userAuthenticationEmail: "fake@gmail.com",
            enablePayPalAppSwitch: true
        )

        payPalClient.tokenize(vaultRequest) { _, _ in }

        XCTAssertTrue(fakeApplication.openURLWasCalled)
        
        let urlComponents = URLComponents(url: fakeApplication.lastOpenURL!, resolvingAgainstBaseURL: true)
        XCTAssertEqual(urlComponents?.host, "www.some-url.com")
        XCTAssertEqual(urlComponents?.path, "/some-path")

        XCTAssertEqual(urlComponents?.queryItems?[0].name, "ba_token")
        XCTAssertEqual(urlComponents?.queryItems?[0].value, "value1")
        XCTAssertEqual(urlComponents?.queryItems?[1].name, "source")
        XCTAssertEqual(urlComponents?.queryItems?[1].value, "braintree_sdk")
        XCTAssertEqual(urlComponents?.queryItems?[2].name, "switch_initiated_time")
        if let urlTimestamp = urlComponents?.queryItems?[2].value {
            XCTAssertNotNil(Int(urlTimestamp))
        } else {
            XCTFail("Expected integer value for query param `switch_initiated_time`")
        }
        XCTAssertEqual(urlComponents?.queryItems?[3].name, "flow_type")
        XCTAssertEqual(urlComponents?.queryItems?[3].value, "va")
        XCTAssertEqual(urlComponents?.queryItems?[4].name, "merchant")
        XCTAssertEqual(urlComponents?.queryItems?[4].value, "testMerchantId")
    }

    func testTokenizeVaultAccount_whenPayPalAppApprovalURLMissingBAToken_returnsError() {
        let fakeApplication = FakeApplication()
        payPalClient.application = fakeApplication

        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "agreementSetup": [
                "paypalAppApprovalUrl": "https://www.some-url.com/some-path?token=value1"
            ]
        ])

        let vaultRequest = BTPayPalVaultRequest(
            userAuthenticationEmail: "fake@gmail.com",
            enablePayPalAppSwitch: true
        )

        let expectation = expectation(description: "completion block called")
        payPalClient.tokenize(vaultRequest) { nonce, error in
            XCTAssertNil(nonce)

            guard let error = error as NSError? else { XCTFail(); return }
            XCTAssertEqual(error.code, 12)
            XCTAssertEqual(error.localizedDescription, "Missing BA Token for PayPal App Switch.")
            XCTAssertEqual(error.domain, "com.braintreepayments.BTPayPalErrorDomain")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testTokenizeVaultAccount_whenOpenURLReturnsFalse_returnsError() {
        let fakeApplication = FakeApplication()
        fakeApplication.cannedOpenURLSuccess = false
        payPalClient.application = fakeApplication

        let vaultRequest = BTPayPalVaultRequest(
            userAuthenticationEmail: "fake@gmail.com",
            enablePayPalAppSwitch: true
        )

        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "agreementSetup": [
                "paypalAppApprovalUrl": "https://www.some-url.com/some-path?ba_token=value1"
            ]
        ])

        payPalClient.tokenize(vaultRequest) { nonce, error in
            XCTAssertNil(nonce)

            if let error = error as NSError? {
                XCTAssertEqual(error.code, 11)
                XCTAssertEqual(error.localizedDescription, "UIApplication failed to perform app switch to PayPal.")
                XCTAssertEqual(error.domain, "com.braintreepayments.BTPayPalErrorDomain")
            }
        }
    }
    
    func testHandleReturn_whenURLIsCancel_returnsCancel() {
        let request = BTPayPalVaultRequest(
            userAuthenticationEmail: "sally@gmail.com",
            enablePayPalAppSwitch: true
        )
        let returnURL = URL(string: "https://www.merchant-app.com/merchant-path/cancel?ba_token=A_FAKE_BA_TOKEN&switch_initiated_time=1234567890")!
        let expectation = expectation(description: "completion block called")

        payPalClient.payPalRequest = request
        payPalClient.didPayPalServerAttemptAppSwitch = true
        
        payPalClient.handleReturn(returnURL, paymentType: .vault) { nonce, error in
            guard let error = error as NSError? else { XCTFail(); return }
            XCTAssertNil(nonce)
            XCTAssertEqual(error.domain, BTPayPalError.errorDomain)
            XCTAssertEqual(error.code, BTPayPalError.canceled.errorCode)
            XCTAssertEqual(error.localizedDescription, BTPayPalError.canceled.errorDescription)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
    
    func testTokenizeCheckoutAccount_whenPayPalAppApprovalURLPresent_attemptsAppSwitchWithParameters() async {
        let fakeApplication = FakeApplication()
        payPalClient.application = fakeApplication

        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": [
                "redirectUrl": "https://www.some-url.com/some-path?token=value1",
                "launchPayPalApp": true
            ]
        ])
        
        let checkoutRequest = BTPayPalCheckoutRequest(
            userAuthenticationEmail: "fake-pp@gmail.com",
            enablePayPalAppSwitch: true,
            amount: "10.00"
        )
        payPalClient.tokenize(checkoutRequest) { _, _ in }

        XCTAssertTrue(fakeApplication.openURLWasCalled)
        
        let urlComponents = URLComponents(url: fakeApplication.lastOpenURL!, resolvingAgainstBaseURL: true)
        XCTAssertEqual(urlComponents?.host, "www.some-url.com")
        XCTAssertEqual(urlComponents?.path, "/some-path")
        
        XCTAssertEqual(urlComponents?.queryItems?[0].name, "token")
        XCTAssertEqual(urlComponents?.queryItems?[0].value, "value1")
        XCTAssertEqual(urlComponents?.queryItems?[1].name, "source")
        XCTAssertEqual(urlComponents?.queryItems?[1].value, "braintree_sdk")
        XCTAssertEqual(urlComponents?.queryItems?[2].name, "switch_initiated_time")
        if let urlTimestamp = urlComponents?.queryItems?[2].value {
            XCTAssertNotNil(urlTimestamp)
        } else {
            XCTFail("Expected integer value for query param `switch_initiated_time`")
        }
        XCTAssertEqual(urlComponents?.queryItems?[3].name, "flow_type")
        XCTAssertEqual(urlComponents?.queryItems?[3].value, "ecs")
        XCTAssertEqual(urlComponents?.queryItems?[4].name, "merchant")
        XCTAssertEqual(urlComponents?.queryItems?[4].value, "testMerchantId")
    }
    
    func testTokenizeCheckoutAccount_whenPayPalAppApprovalURLMissingECToken_returnsError() {
        let fakeApplication = FakeApplication()
        payPalClient.application = fakeApplication
        
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": [
                "redirectUrl": "https://www.some-url.com/some-path",
                "launchPayPalApp": true
            ]
        ])
        
        let checkoutRequest = BTPayPalCheckoutRequest(
            userAuthenticationEmail: "fake-pp@gmail.com",
            enablePayPalAppSwitch: true,
            amount: "10.00"
        )
        
        let expectation = expectation(description: "completion block called")
        payPalClient.tokenize(checkoutRequest) { nonce, error in
            XCTAssertNil(nonce)
            
            guard let error = error as NSError? else { XCTFail(); return }
            XCTAssertEqual(error.code, 14)
            XCTAssertEqual(error.localizedDescription, "Missing EC Token for PayPal App Switch.")
            XCTAssertEqual(error.domain, "com.braintreepayments.BTPayPalErrorDomain")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }

    func testHandleReturn_whenURLIsUnknown_returnsError() {
        let request = BTPayPalVaultRequest(
            userAuthenticationEmail: "sally@gmail.com",
            enablePayPalAppSwitch: true
        )
        let returnURL = URL(string: "https://www.merchant-app.com/merchant-path/garbage-url")!
        let expectation = expectation(description: "completion block called")

        payPalClient.payPalRequest = request
        payPalClient.handleReturn(returnURL, paymentType: .vault) { nonce, error in
            guard let error = error as NSError? else { XCTFail(); return }
            XCTAssertNil(nonce)
            XCTAssertEqual(error.domain, BTPayPalError.errorDomain)
            XCTAssertEqual(error.code, BTPayPalError.invalidURLAction.errorCode)
            XCTAssertEqual(error.localizedDescription, BTPayPalError.invalidURLAction.errorDescription)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testHandleReturn_whenURLIsSuccess_returnsTokenization() {
        let request = BTPayPalVaultRequest(
            userAuthenticationEmail: "sally@gmail.com",
            enablePayPalAppSwitch: true
        )
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

        let returnURL = URL(string: "https://www.merchant-app.com/merchant-path/success?token=A_FAKE_EC_TOKEN&ba_token=A_FAKE_BA_TOKEN&switch_initiated_time=1234567890.1234")
        let expectation = expectation(description: "completion block called")

        payPalClient.payPalRequest = request
        payPalClient.didPayPalServerAttemptAppSwitch = true

        payPalClient.handleReturn(returnURL, paymentType: .vault) { nonce, error in
            XCTAssertNil(error)
            XCTAssertNotNil(nonce)
            XCTAssertEqual(nonce?.nonce, "a-nonce")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testHandleReturnURL_whenReturnURLIsInvalid_returnsError() {
        let expectation = expectation(description: "completion block called")
        payPalClient.appSwitchCompletion = { nonce, error in
            guard let error = error as NSError? else { XCTFail(); return }
            XCTAssertNil(nonce)
            XCTAssertEqual(error.domain, BTPayPalError.errorDomain)
            XCTAssertEqual(error.code, BTPayPalError.appSwitchReturnURLPathInvalid.errorCode)
            XCTAssertEqual(error.localizedDescription, "The App Switch return URL did not contain the cancel or success path.")
            expectation.fulfill()
        }

        payPalClient.handleReturnURL(URL(string: "https://merchant-app.com/merchant-path/garbage")!)
        waitForExpectations(timeout: 1)
    }

    func testIsiOSAppSwitchAvailable_whenApplicationCanOpenPayPalInAppURL_returnsTrueAndSendsAnalytics() {
        let fakeApplication = FakeApplication()
        fakeApplication.cannedCanOpenURL = true
        payPalClient.application = fakeApplication

        let vaultRequest = BTPayPalVaultRequest(
            userAuthenticationEmail: "fake@gmail.com",
            enablePayPalAppSwitch: true
        )

        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "agreementSetup": [
                "paypalAppApprovalUrl": "https://www.some-url.com/some-path?token=value1"
            ]
        ])

        payPalClient.tokenize(vaultRequest) { _, _ in }

        XCTAssertEqual("v1/paypal_hermes/setup_billing_agreement", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else { XCTFail(); return }

        XCTAssertEqual(lastPostParameters["launch_paypal_app"] as? Bool, true)
        XCTAssertTrue((lastPostParameters["os_version"] as! String).matches("\\d+\\.\\d+"))
        XCTAssertTrue((lastPostParameters["os_type"] as! String).matches("iOS|iPadOS"))
        XCTAssertEqual(lastPostParameters["merchant_app_return_url"] as? String, "https://www.paypal.com/braintreeAppSwitchPayPal")
    }

    func testIsiOSAppSwitchAvailable_whenApplicationCantOpenPayPalInAppURL_returnsFalseAndSendsAnalytics() {
        let fakeApplication = FakeApplication()
        fakeApplication.cannedCanOpenURL = false
        payPalClient.application = fakeApplication

        let vaultRequest = BTPayPalVaultRequest(
            userAuthenticationEmail: "fake@gmail.com",
            enablePayPalAppSwitch: true
        )

        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "agreementSetup": [
                "paypalAppApprovalUrl": "https://www.some-url.com/some-path?token=value1"
            ]
        ])

        payPalClient.tokenize(vaultRequest) { _, _ in }

        XCTAssertEqual("v1/paypal_hermes/setup_billing_agreement", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else { XCTFail(); return }

        XCTAssertNil(lastPostParameters["launch_paypal_app"] as? Bool)
        XCTAssertNil(lastPostParameters["os_version"] as? String)
        XCTAssertNil(lastPostParameters["os_type"] as? String)
        XCTAssertNil(lastPostParameters["merchant_app_return_url"] as? String)
    }

    func testInvokedOpenURLSuccessfully_whenSuccess_sendsAppSwitchSucceededWithAppSwitchURL() {
        let eventName = BTPayPalAnalytics.appSwitchSucceeded
        let fakeURL = URL(string: "some-url")!
        payPalClient.invokedOpenURLSuccessfully(true, url: fakeURL) { _, _ in }

        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.last!, eventName)
        XCTAssertEqual(mockAPIClient.postedAppSwitchURL[eventName], fakeURL.absoluteString)
    }

    func testInvokedOpenURLSuccessfully_whenFailure_sendsAppSwitchFailedWithAppSwitchURL() {
        let eventName = BTPayPalAnalytics.appSwitchFailed
        let fakeURL = URL(string: "some-url")!
        payPalClient.invokedOpenURLSuccessfully(false, url: fakeURL) { _, _ in }

        XCTAssertEqual(mockAPIClient.postedAnalyticsEvents.first!, eventName)
        XCTAssertEqual(mockAPIClient.postedAppSwitchURL[eventName], fakeURL.absoluteString)
    }
    
    func testTokenize_calledMultipleTimes_onlyCallsOpenOnce() {
        let fakeApplication = FakeApplication()
        payPalClient.application = fakeApplication
                
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "agreementSetup": [
                "paypalAppApprovalUrl": "https://www.some-url.com/some-path?ba_token=value1"
            ]
        ])

        let vaultRequest = BTPayPalVaultRequest(enablePayPalAppSwitch: true)
        
        let returnURL = URL(string: "https://www.merchant-app.com/merchant-path/success?ba_token=A_FAKE_BA_TOKEN&switch_initiated_time=1234567890")!
    
        payPalClient.tokenize(vaultRequest) { _, _ in }
        
        XCTAssertTrue(self.payPalClient.hasOpenedURL)
        
        payPalClient.tokenize(vaultRequest) { _, _ in }
        
        payPalClient.handleReturnURL(returnURL)
                
        XCTAssertFalse(self.payPalClient.hasOpenedURL)
        XCTAssertEqual(fakeApplication.openCallCount, 1)
    }
    
    func testTokenize_whenAppSwitchAttempted_usesUniversalLinksOnlyOption() {
        let fakeApplication = FakeApplication()
        payPalClient.application = fakeApplication

        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "agreementSetup": [
                "paypalAppApprovalUrl": "https://www.some-url.com/some-path?ba_token=value1"
            ]
        ])

        let vaultRequest = BTPayPalVaultRequest(enablePayPalAppSwitch: true)
        
        payPalClient.tokenize(vaultRequest) { _, _ in }
        
        XCTAssertTrue(fakeApplication.openURLWasCalled)
        XCTAssertNotNil(fakeApplication.lastOpenOptions)
        XCTAssertEqual(fakeApplication.lastOpenOptions?[.universalLinksOnly] as? NSNumber, true as NSNumber)
    }
    
    func testTokenize_whenAppSwitchFails_opensInDefaultBrowserWithAnalytics() {
        let fakeApplication = FakeApplication()
        fakeApplication.cannedOpenURLSuccess = false
        payPalClient.application = fakeApplication

        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "agreementSetup": [
                "paypalAppApprovalUrl": "https://www.some-url.com/some-path?ba_token=value1"
            ]
        ])

        let vaultRequest = BTPayPalVaultRequest(enablePayPalAppSwitch: true)
        
        payPalClient.tokenize(vaultRequest) { _, _ in }
        
        XCTAssertTrue(fakeApplication.openURLWasCalled)
        XCTAssertEqual(fakeApplication.openCallCount, 2)
        
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTPayPalAnalytics.appSwitchFailed))
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTPayPalAnalytics.defaultBrowserStarted))
    }
    
    func testTokenize_whenDefaultBrowserSwitchSucceeds_sendsDefaultBrowserSucceededAnalytics() {
        let fakeApplication = FakeApplication()
        fakeApplication.cannedOpenURLSuccessPerCall = [.universalLinksOnly: false, .none: true]
        payPalClient.application = fakeApplication

        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "agreementSetup": [
                "paypalAppApprovalUrl": "https://www.some-url.com/some-path?ba_token=value1"
            ]
        ])

        let vaultRequest = BTPayPalVaultRequest(enablePayPalAppSwitch: true)
        
        payPalClient.tokenize(vaultRequest) { _, _ in }
        
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTPayPalAnalytics.appSwitchFailed))
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTPayPalAnalytics.defaultBrowserStarted))
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTPayPalAnalytics.defaultBrowserSucceeded))
    }
    
    func testTokenize_whenDefaultBrowserSwitchFails_sendsDefaultBrowserFailedAnalytics() {
        let fakeApplication = FakeApplication()
        fakeApplication.cannedOpenURLSuccess = false
        payPalClient.application = fakeApplication

        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "agreementSetup": [
                "paypalAppApprovalUrl": "https://www.some-url.com/some-path?ba_token=value1"
            ]
        ])

        let vaultRequest = BTPayPalVaultRequest(enablePayPalAppSwitch: true)
        
        let expectation = expectation(description: "completion block called")
        payPalClient.tokenize(vaultRequest) { nonce, error in
            XCTAssertNil(nonce)
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTPayPalAnalytics.appSwitchFailed))
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTPayPalAnalytics.defaultBrowserStarted))
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTPayPalAnalytics.defaultBrowserFailed))
    }
    
    func testTokenizeCheckout_whenAppSwitchFails_opensInDefaultBrowserWithAnalytics() {
        let fakeApplication = FakeApplication()
        fakeApplication.cannedOpenURLSuccess = false
        payPalClient.application = fakeApplication

        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": [
                "redirectUrl": "https://www.some-url.com/some-path?token=value1",
                "launchPayPalApp": true
            ]
        ])

        let checkoutRequest = BTPayPalCheckoutRequest(
            userAuthenticationEmail: "fake-pp@gmail.com",
            enablePayPalAppSwitch: true,
            amount: "10.00"
        )
        
        payPalClient.tokenize(checkoutRequest) { _, _ in }
        
        XCTAssertTrue(fakeApplication.openURLWasCalled)
        XCTAssertEqual(fakeApplication.openCallCount, 2)
        
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTPayPalAnalytics.appSwitchFailed))
        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains(BTPayPalAnalytics.defaultBrowserStarted))
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
        payPalClient.handleReturn(returnURL, paymentType: .vault) { _, _ in }

        XCTAssertFalse(mockAPIClient.postedAnalyticsEvents.contains("ios.paypal-ba.credit.accepted"))
    }

    func testTokenize_whenVaultRequest_setsVaultAnalyticsTags() async {
        let vaultRequest = BTPayPalVaultRequest()

        let _ = try? await payPalClient.tokenize(vaultRequest)

        XCTAssertTrue(mockAPIClient.postedIsVaultRequest)
        XCTAssertEqual(mockAPIClient.postedContextType, "BA-TOKEN")
    }

    func testTokenize_whenCheckoutRequest_setsVaultAnalyticsTags() async {
        let checkoutRequest = BTPayPalCheckoutRequest(amount: "2.00")

        let _ = try? await payPalClient.tokenize(checkoutRequest)

        XCTAssertFalse(mockAPIClient.postedIsVaultRequest)
        XCTAssertEqual(mockAPIClient.postedContextType, "EC-TOKEN")
    }
    
    func testTokenize_whenShopperSessionIDSetOnRequest_includesInAnalytics() async {
        let checkoutRequest = BTPayPalCheckoutRequest(amount: "2.00")
        checkoutRequest.shopperSessionID = "fake-shopper-session-id"
        
        let _ = try? await payPalClient.tokenize(checkoutRequest)

        XCTAssertEqual(mockAPIClient.postedShopperSessionID, "fake-shopper-session-id")
    }
    
    func testTokenize_whenSuccess_sendsApplicationStateInAnalytics() async {
        let vaultRequest = BTPayPalVaultRequest()

        let _ = try? await payPalClient.tokenize(vaultRequest)

        XCTAssertEqual(mockAPIClient.postedApplicationState, "active")
    }
}
