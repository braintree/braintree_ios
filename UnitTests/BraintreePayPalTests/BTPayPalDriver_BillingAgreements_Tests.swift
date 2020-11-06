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
        XCTAssertEqual(lastPostParameters["return_url"] as? String, "sdk.ios.braintree://onetouch/v1/success")
        XCTAssertEqual(lastPostParameters["cancel_url"] as? String, "sdk.ios.braintree://onetouch/v1/cancel")
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

    func testBillingAgreement_whenBrowserSwitchSucceeds_tokenizesPayPalAccount() {
        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        payPalDriver.handleBrowserSwitchReturn(returnURL, paymentType: .billingAgreement) { (_, _) in }

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

    func testBillingAgreement_whenBrowserSwitchCancels_callsBackWithNoResultAndError() {
        let returnURL = URL(string: "bar://onetouch/v1/cancel?token=hermes_token")!

        let expectation = self.expectation(description: "completion block called")
        
        payPalDriver.handleBrowserSwitchReturn(returnURL, paymentType: .billingAgreement) { (nonce, error) in
            XCTAssertNil(nonce)
            XCTAssertEqual((error! as NSError).domain, BTPayPalDriverErrorDomain)
            XCTAssertEqual((error! as NSError).code, BTPayPalDriverErrorType.canceled.rawValue)
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1)
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

        XCTAssertNotNil(payPalDriver.authenticationSession)
        XCTAssertTrue(payPalDriver.isAuthenticationSessionStarted)
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

    func testBillingAgreement_makesContextSwitchDelegateCallbacks() {
        let mockAppSwitchDelegate = MockAppSwitchDelegate()
        payPalDriver.appSwitchDelegate = mockAppSwitchDelegate

        payPalDriver.requestBillingAgreement(BTPayPalRequest(amount: "1")) { _,_ in }

        XCTAssertNotNil(payPalDriver.authenticationSession)
        XCTAssertTrue(payPalDriver.isAuthenticationSessionStarted)

        XCTAssertTrue(mockAppSwitchDelegate.appContextWillSwitchCalled)
        XCTAssertFalse(mockAppSwitchDelegate.appContextDidReturnCalled)

        let returnURL = URL(string: "bar://hello/world")!
        payPalDriver.handleBrowserSwitchReturn(returnURL, paymentType: .billingAgreement) { (_, _) in }

        XCTAssertNotNil(payPalDriver.authenticationSession)
        XCTAssertTrue(payPalDriver.isAuthenticationSessionStarted)
        XCTAssertTrue(mockAppSwitchDelegate.appContextDidReturnCalled)
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

        let returnURL = URL(string: "bar://hello/world")!
        payPalDriver.handleBrowserSwitchReturn(returnURL, paymentType: .billingAgreement) { (_, _) in }

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

        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        payPalDriver.handleBrowserSwitchReturn(returnURL, paymentType: .billingAgreement) { (_, _) in }

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
