import XCTest
import BraintreePayPal
import BraintreeTestShared
import SafariServices

class BTPayPalDriver_BillingAgreements_Tests: XCTestCase {
    var mockAPIClient: MockAPIClient!
    var payPalDriver: BTPayPalDriver!

    override func setUp() {
        super.setUp()

        mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "paypal": [
                "environment": "offline"
            ] ])
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": [
                "redirectUrl": "http://fakeURL.com"
            ] ])
        payPalDriver = BTPayPalDriver(apiClient: mockAPIClient)
        payPalDriver.returnURLScheme = "foo"
    }

    func testBillingAgreement_whenAPIClientIsNil_callsBackWithError() {
        payPalDriver.apiClient = nil

        let request = BTPayPalRequest(amount: "1")
        let expectation = self.expectation(description: "Billing Agreement fails with error")
        payPalDriver.requestBillingAgreement(request) { (tokenizedPayPalAccount, error) -> Void in
            XCTAssertNil(tokenizedPayPalAccount)
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTPayPalDriverErrorDomain)
            XCTAssertEqual(error.code, BTPayPalDriverErrorType.integration.rawValue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testBillingAgreement_whenRemoteConfigurationFetchFails_callsBackWithConfigurationError() {
        mockAPIClient.cannedConfigurationResponseBody = nil
        mockAPIClient.cannedConfigurationResponseError = NSError(domain: "", code: 0, userInfo: nil)

        let request = BTPayPalRequest()
        let expectation = self.expectation(description: "Checkout fails with error")
        payPalDriver.requestBillingAgreement(request) { (_, error) -> Void in
            XCTAssertEqual(error! as NSError, self.mockAPIClient.cannedConfigurationResponseError!)
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1)
    }

    func testBillingAgreement_whenRemoteConfigurationFetchSucceeds_postsSetupBillingAgreement() {
        payPalDriver.requestBillingAgreement(BTPayPalRequest()) { _,_  -> Void in }

        XCTAssertEqual("v1/paypal_hermes/setup_billing_agreement", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        XCTAssertEqual(lastPostParameters["return_url"] as? String, "foo://onetouch/v1/success")
        XCTAssertEqual(lastPostParameters["cancel_url"] as? String, "foo://onetouch/v1/cancel")
        XCTAssertEqual(lastPostParameters["offer_paypal_credit"] as? Bool, false)
    }

    func testBillingAgreement_whenMerchantAccountIdIsSet_postsPaymentResourceWithMerchantAccountId() {
        let merchantAccountId = "alternate-merchant-account-id"
        let request = BTPayPalRequest()
        request.merchantAccountId = merchantAccountId

        payPalDriver.requestBillingAgreement(request) { _,_  -> Void in }

        XCTAssertEqual("v1/paypal_hermes/setup_billing_agreement", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        XCTAssertEqual(lastPostParameters["merchant_account_id"] as? String, merchantAccountId)
    }

    func testBillingAgreement_whenPayPalCreditOffered_performsSwitchCorrectly() {
        let request = BTPayPalRequest()
        request.offerCredit = true

        payPalDriver.requestBillingAgreement(request) { _,_  in }

        XCTAssertNotNil(payPalDriver.safariAuthenticationSession)
        XCTAssertTrue(payPalDriver.isSFAuthenticationSessionStarted)

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

    func testBillingAgreement_whenAppSwitchSucceeds_tokenizesPayPalAccount() {
        payPalDriver.setBillingAgreementAppSwitchReturn ({ _,_  -> Void in })
        BTPayPalDriver.handleAppSwitchReturn(URL(string: "bar://onetouch/v1/success?token=hermes_token")!)

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

    func testBillingAgreement_whenConfigurationHasCurrency_doesNotSendCurrencyOrIntentViaPOSTParameters() {
        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "paypal": [
                "environment": "offline",
                "currencyIsoCode": "GBP",
            ] ])

        payPalDriver.requestBillingAgreement(BTPayPalRequest()) { _,_  -> Void in }

        XCTAssertEqual("v1/paypal_hermes/setup_billing_agreement", mockAPIClient.lastPOSTPath)
        XCTAssertNotNil(mockAPIClient.lastPOSTParameters)
        XCTAssertNil(mockAPIClient.lastPOSTParameters?["currency_iso_code"])
        XCTAssertNil(mockAPIClient.lastPOSTParameters?["intent"])
    }

    func testBillingAgreement_whenCheckoutRequestHasCurrency_doesNotSendCurrencyViaPOSTParameters() {
        let request = BTPayPalRequest()
        request.currencyCode = "GBP"

        payPalDriver.requestBillingAgreement(request) { _,_  -> Void in }

        XCTAssertEqual("v1/paypal_hermes/setup_billing_agreement", mockAPIClient.lastPOSTPath)
        XCTAssertNotNil(mockAPIClient.lastPOSTParameters)
        XCTAssertNil(mockAPIClient.lastPOSTParameters?["currency_iso_code"])
    }

    func testBillingAgreement_whenRequestHasBillingAgreementDescription_sendsDescriptionInParameters() {
        let request = BTPayPalRequest()
        request.billingAgreementDescription = "My Billing Agreement description"

        payPalDriver.requestBillingAgreement(request) { _,_  -> Void in }

        XCTAssertEqual("v1/paypal_hermes/setup_billing_agreement", mockAPIClient.lastPOSTPath)
        XCTAssertNotNil(mockAPIClient.lastPOSTParameters)
        XCTAssertEqual(mockAPIClient.lastPOSTParameters?["description"] as? String, "My Billing Agreement description")
    }

    func testBillingAgreement_whenSetupBillingAgreementCreationSuccessful_performsPayPalRequestAppSwitch() {
        payPalDriver.requestBillingAgreement(BTPayPalRequest()) { _,_  -> Void in }

        XCTAssertNotNil(payPalDriver.safariAuthenticationSession)
        XCTAssertTrue(payPalDriver.isSFAuthenticationSessionStarted)
    }

    func testBillingAgreement_whenSetupBillingAgreementCreationFails_callsBackWithError() {
        mockAPIClient.cannedResponseError = NSError(domain: "", code: 0, userInfo: nil)

        let expectation = self.expectation(description: "Checkout fails with error")

        payPalDriver.requestBillingAgreement(BTPayPalRequest()) { (_, error) -> Void in
            XCTAssertEqual(error! as NSError, self.mockAPIClient.cannedResponseError!)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 1)
    }


    func testBillingAgreement_whenSFSafariViewControllerIsAvailable_callsViewControllerPresentationDelegateMethods() {
        let mockDelegate = MockViewControllerPresentationDelegate()

        // Setup for requestsPresentationOfViewController
        mockDelegate.requestsPresentationOfViewControllerExpectation = self.expectation(description: "Delegate received requestsPresentationOfViewController")

        payPalDriver.viewControllerPresentingDelegate = mockDelegate
        payPalDriver.informDelegatePresentingViewControllerRequestPresent(URL(string: "http://example.com")!)

        self.waitForExpectations(timeout: 1)

        XCTAssertNotNil(mockDelegate.lastViewController)
        XCTAssertEqual(mockDelegate.lastViewController, payPalDriver.safariViewController)
        XCTAssertEqual(mockDelegate.lastPaymentDriver as? BTPayPalDriver, payPalDriver)

        let safariViewController = payPalDriver.safariViewController

        mockDelegate.lastViewController = nil
        mockDelegate.lastPaymentDriver = nil

        // Setup for requestsDismissalOfViewController
        mockDelegate.requestsDismissalOfViewControllerExpectation = self.expectation(description: "Delegate received requestsDismissalOfViewController")
        payPalDriver.informDelegatePresentingViewControllerNeedsDismissal()

        self.waitForExpectations(timeout: 1)

        XCTAssertNotNil(mockDelegate.lastViewController)
        XCTAssertEqual(mockDelegate.lastViewController, safariViewController)
        XCTAssertNil(payPalDriver.safariViewController)
        XCTAssertEqual(mockDelegate.lastPaymentDriver as? BTPayPalDriver, payPalDriver)
    }

    // TODO: - do we want to throw an error instead of just logging?
    func testBillingAgreement_whenSFSafariViewControllerIsAvailableButNoViewControllerPresentingDelegateSet_logsError() {
        let payPalDriver = BTPayPalDriver(apiClient: mockAPIClient)

        var criticalMessageLogged = false
        BTLogger.shared().logBlock = {
            (level: BTLogLevel, message: String?) in
            if (level == BTLogLevel.critical && message == "Unable to display View Controller to continue PayPal flow. BTPayPalDriver needs a viewControllerPresentingDelegate<BTViewControllerPresentingDelegate> to be set.") {
                criticalMessageLogged = true
            }
            return
        }

        payPalDriver.informDelegatePresentingViewControllerRequestPresent(URL(string: "http://example.com")!)
        XCTAssertTrue(criticalMessageLogged)
    }

    func testBillingAgreement_whenSFSafariViewControllerIsAvailable_doesNotCallAppSwitchDelegateMethods() {
        let mockAppSwitchDelegate = MockAppSwitchDelegate()
        payPalDriver.appSwitchDelegate = mockAppSwitchDelegate
        payPalDriver.requestBillingAgreement(BTPayPalRequest(amount: "1")) { _,_ in }

        XCTAssertNotNil(payPalDriver.safariAuthenticationSession)
        XCTAssertTrue(payPalDriver.isSFAuthenticationSessionStarted)

        XCTAssertFalse(mockAppSwitchDelegate.willPerformAppSwitchCalled)
        XCTAssertFalse(mockAppSwitchDelegate.didPerformAppSwitchCalled)

        BTPayPalDriver.handleAppSwitchReturn(URL(string: "bar://hello/world")!)

        XCTAssertNotNil(payPalDriver.safariAuthenticationSession)
        XCTAssertTrue(payPalDriver.isSFAuthenticationSessionStarted)

        XCTAssertFalse(mockAppSwitchDelegate.willProcessAppSwitchCalled)
    }

    func testBillingAgreement_whenSFSafariViewControllerIsAvailable_makesContextSwitchDelegateCallbacks() {
        let mockAppSwitchDelegate = MockAppSwitchDelegate()
        payPalDriver.appSwitchDelegate = mockAppSwitchDelegate

        payPalDriver.requestBillingAgreement(BTPayPalRequest(amount: "1")) { _,_ in }

        XCTAssertNotNil(payPalDriver.safariAuthenticationSession)
        XCTAssertTrue(payPalDriver.isSFAuthenticationSessionStarted)

        XCTAssertTrue(mockAppSwitchDelegate.appContextWillSwitchCalled)
        XCTAssertFalse(mockAppSwitchDelegate.appContextDidReturnCalled)

        BTPayPalDriver.handleAppSwitchReturn(URL(string: "bar://hello/world")!)

        XCTAssertNotNil(payPalDriver.safariAuthenticationSession)
        XCTAssertTrue(payPalDriver.isSFAuthenticationSessionStarted)
        XCTAssertTrue(mockAppSwitchDelegate.appContextDidReturnCalled)
    }

    // TODO: - it doesn't seem like this is testing what it claims to be
    func testBillingAgreement_whenUsingCustomHandler_callsHandleApprovalDelegateMethod() {
        let mockHandler = MockPayPalApprovalHandlerDelegate()
        mockHandler.url = URL(string: "some://url")

        mockHandler.handleApprovalExpectation = self.expectation(description: "Delegate received handleApproval")
        let blockExpectation = self.expectation(description: "Completion block reached")
        payPalDriver.requestBillingAgreement(BTPayPalRequest(), handler: mockHandler) { (_, _) in
            XCTAssertNotNil(mockHandler);
            blockExpectation.fulfill()
        }

        self.waitForExpectations(timeout: 1)
    }

    func testBillingAgreement_whenCreditFinancingNotReturned_shouldNotSendCreditAcceptedAnalyticsEvent() {
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
        payPalDriver.payPalRequest = BTPayPalRequest()

        payPalDriver.setBillingAgreementAppSwitchReturn ({ _,_  -> Void in })
        BTPayPalDriver.handleAppSwitchReturn(URL(string: "bar://hello/world")!)

        XCTAssertFalse(mockAPIClient.postedAnalyticsEvents.contains("ios.paypal-ba.credit.accepted"))
    }

    func testBillingAgreement_whenCreditFinancingReturned_shouldSendCreditAcceptedAnalyticsEvent() {
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

        payPalDriver.payPalRequest = BTPayPalRequest()

        payPalDriver.setBillingAgreementAppSwitchReturn ({ _,_  -> Void in })
        BTPayPalDriver.handleAppSwitchReturn(URL(string: "bar://onetouch/v1/success?hermes_token")!)

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("ios.paypal-ba.credit.accepted"))
    }

    func testBillingAgreement_whenRemoteConfigurationFetchSucceeds_postsPaymentResourceWithShippingAddress() {
        let request = BTPayPalRequest()
        request.currencyCode = "GBP"
        let address = BTPostalAddress()
        address.streetAddress = "1234 Fake St."
        address.extendedAddress = "Apt. 0"
        address.region = "CA"
        address.locality = "Oakland"
        address.countryCodeAlpha2 = "US"
        address.postalCode = "12345"
        request.shippingAddressOverride = address
        payPalDriver.requestBillingAgreement(request) { _,_ in }

        XCTAssertEqual("v1/paypal_hermes/setup_billing_agreement", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        guard let experienceProfile = lastPostParameters["experience_profile"] as? [String:Any] else {
            XCTFail()
            return
        }
        guard let shippingAddress = lastPostParameters["shipping_address"] as? [String:Any] else {
            XCTFail()
            return
        }
        XCTAssertEqual(lastPostParameters["offer_paypal_credit"] as? Bool, false)
        XCTAssertEqual(experienceProfile["address_override"] as? Bool, true)
        XCTAssertEqual(shippingAddress["line1"] as? String, "1234 Fake St.")
        XCTAssertEqual(shippingAddress["line2"] as? String, "Apt. 0")
        XCTAssertEqual(shippingAddress["city"] as? String, "Oakland")
        XCTAssertEqual(shippingAddress["state"] as? String, "CA")
        XCTAssertEqual(shippingAddress["postal_code"] as? String, "12345")
        XCTAssertEqual(shippingAddress["country_code"] as? String, "US")
    }

    func testBillingAgreement_whenRemoteConfigurationFetchSucceeds_postsPaymentResourceWithPartialShippingAddress() {
        let request = BTPayPalRequest()
        request.currencyCode = "GBP"
        let address : BTPostalAddress = BTPostalAddress()
        address.streetAddress = "1234 Fake St."
        address.region = "CA"
        address.locality = "Oakland"
        address.countryCodeAlpha2 = "US"
        address.postalCode = "12345"
        request.shippingAddressOverride = address
        payPalDriver.requestBillingAgreement(request) { _,_  -> Void in }

        XCTAssertEqual("v1/paypal_hermes/setup_billing_agreement", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        guard let experienceProfile = lastPostParameters["experience_profile"] as? [String:Any] else {
            XCTFail()
            return
        }
        guard let shippingAddress = lastPostParameters["shipping_address"] as? [String:Any] else {
            XCTFail()
            return
        }
        XCTAssertEqual(lastPostParameters["offer_paypal_credit"] as? Bool, false)
        XCTAssertEqual(experienceProfile["address_override"] as? Bool, true)
        XCTAssertEqual(shippingAddress["line1"] as? String, "1234 Fake St.")
        XCTAssertNil(shippingAddress["line2"])
        XCTAssertEqual(shippingAddress["city"] as? String, "Oakland")
        XCTAssertEqual(shippingAddress["state"] as? String, "CA")
        XCTAssertEqual(shippingAddress["postal_code"] as? String, "12345")
        XCTAssertEqual(shippingAddress["country_code"] as? String, "US")
    }

    func testBillingAgreement_postsPaymentResourceWithShippingAddressEditable() {
        let request = BTPayPalRequest()
        request.currencyCode = "GBP"
        let address : BTPostalAddress = BTPostalAddress()
        request.shippingAddressOverride = address
        request.isShippingAddressEditable = true
        payPalDriver.requestBillingAgreement(request) { _,_  -> Void in }

        XCTAssertEqual("v1/paypal_hermes/setup_billing_agreement", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        guard let experienceProfile = lastPostParameters["experience_profile"] as? [String:Any] else {
            XCTFail()
            return
        }
        XCTAssertEqual(experienceProfile["address_override"] as? Bool, false)
    }
}
