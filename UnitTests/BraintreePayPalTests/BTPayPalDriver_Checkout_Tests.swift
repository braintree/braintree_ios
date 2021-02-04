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

        let request = BTPayPalRequest(amount: "1")
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

        let request = BTPayPalRequest(amount: "1")
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

    func testCheckout_whenRemoteConfigurationFetchSucceeds_postsPaymentResource() {
        let request = BTPayPalRequest(amount: "1")
        request.currencyCode = "GBP"
        payPalDriver.requestOneTimePayment(request) { _,_  -> Void in }

        XCTAssertEqual("v1/paypal_hermes/create_payment_resource", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        XCTAssertEqual(lastPostParameters["amount"] as? String, "1")
        XCTAssertEqual(lastPostParameters["currency_iso_code"] as? String, "GBP")
        XCTAssertEqual(lastPostParameters["return_url"] as? String, "sdk.ios.braintree://onetouch/v1/success")
        XCTAssertEqual(lastPostParameters["cancel_url"] as? String, "sdk.ios.braintree://onetouch/v1/cancel")
    }

    func testCheckout_byDefault_postsPaymentResourceWithNoShipping() {
        let request = BTPayPalRequest(amount: "1")
        request.currencyCode = "GBP"
        // no_shipping = true should be the default.
        payPalDriver.requestOneTimePayment(request) { _,_  -> Void in }

        XCTAssertEqual("v1/paypal_hermes/create_payment_resource", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        guard let experienceProfile = lastPostParameters["experience_profile"] as? [String:Any] else {
            XCTFail()
            return
        }
        XCTAssertEqual(experienceProfile["no_shipping"] as? Bool, true)
    }

    func testCheckout_whenShippingAddressIsRequired_postsPaymentResourceWithNoShippingAsFalse() {
        let request = BTPayPalRequest(amount: "1")
        request.currencyCode = "GBP"
        request.isShippingAddressRequired = true
        payPalDriver.requestOneTimePayment(request) { _,_  -> Void in }

        XCTAssertEqual("v1/paypal_hermes/create_payment_resource", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        guard let experienceProfile = lastPostParameters["experience_profile"] as? [String:Any] else {
            XCTFail()
            return
        }
        XCTAssertEqual(experienceProfile["no_shipping"] as? Bool, false)
    }

    func testCheckout_whenIntentIsNotSpecified_postsPaymentResourceWithAuthorizeIntent() {
        let request = BTPayPalRequest(amount: "1")
        request.currencyCode = "GBP"
        request.isShippingAddressRequired = true

        payPalDriver.requestOneTimePayment(request) { _,_  -> Void in }

        XCTAssertEqual("v1/paypal_hermes/create_payment_resource", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        XCTAssertEqual(lastPostParameters["intent"] as? String, "authorize")
        XCTAssertEqual(request.intent, BTPayPalRequestIntent.authorize)
    }

    func testCheckout_whenIntentIsSetToAuthorize_postsPaymentResourceWithIntent() {
        let request = BTPayPalRequest(amount: "1")
        request.currencyCode = "GBP"
        request.intent = .authorize;
        request.isShippingAddressRequired = true

        payPalDriver.requestOneTimePayment(request) { _,_  -> Void in }

        XCTAssertEqual("v1/paypal_hermes/create_payment_resource", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        XCTAssertEqual(lastPostParameters["intent"] as? String, "authorize")
    }

    func testCheckout_whenIntentIsSetToSale_postsPaymentResourceWithIntent() {
        let request = BTPayPalRequest(amount: "1")
        request.currencyCode = "GBP"
        request.intent = .sale;
        request.isShippingAddressRequired = true

        payPalDriver.requestOneTimePayment(request) { _,_  -> Void in }

        XCTAssertEqual("v1/paypal_hermes/create_payment_resource", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        XCTAssertEqual(lastPostParameters["intent"] as? String, "sale")
    }

    func testCheckout_whenIntentIsSetToOrder_postsPaymentResourceWithIntent() {
        let request = BTPayPalRequest(amount: "1")
        request.currencyCode = "GBP"
        request.intent = .order;
        request.isShippingAddressRequired = true

        payPalDriver.requestOneTimePayment(request) { _,_  -> Void in }

        XCTAssertEqual("v1/paypal_hermes/create_payment_resource", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        XCTAssertEqual(lastPostParameters["intent"] as? String, "order")
    }

    func testCheckout_whenLandingPageTypeIsNotSpecified_doesNotPostPaymentResourceWithLandingPageType() {
        let request = BTPayPalRequest(amount: "1")
        request.currencyCode = "GBP"
        XCTAssertEqual(BTPayPalRequestLandingPageType.default, request.landingPageType)

        payPalDriver.requestOneTimePayment(request) { _,_  -> Void in }

        XCTAssertEqual("v1/paypal_hermes/create_payment_resource", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }

        guard let experienceProfile = lastPostParameters["experience_profile"] as? [String:Any] else {
            XCTFail()
            return
        }
        XCTAssertNil(experienceProfile["landing_page_type"])
    }

    func testCheckout_whenLandingPageTypeIsBilling_postsPaymentResourceWithBillingLandingPageType() {
        let request = BTPayPalRequest(amount: "1")
        request.currencyCode = "GBP"
        request.landingPageType = .billing

        payPalDriver.requestOneTimePayment(request) { _,_  -> Void in }

        XCTAssertEqual("v1/paypal_hermes/create_payment_resource", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }

        guard let experienceProfile = lastPostParameters["experience_profile"] as? [String:Any] else {
            XCTFail()
            return
        }
        XCTAssertEqual(experienceProfile["landing_page_type"] as? String, "billing")
    }

    func testCheckout_whenLandingPageTypeIsLogin_postsPaymentResourceWithLoginLandingPageType() {
        let request = BTPayPalRequest(amount: "1")
        request.currencyCode = "GBP"
        request.landingPageType = .login

        payPalDriver.requestOneTimePayment(request) { _,_  -> Void in }

        XCTAssertEqual("v1/paypal_hermes/create_payment_resource", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }

        guard let experienceProfile = lastPostParameters["experience_profile"] as? [String:Any] else {
            XCTFail()
            return
        }
        XCTAssertEqual(experienceProfile["landing_page_type"] as? String, "login")
    }

    func testCheckout_whenPaymentResourceCreationFails_callsBackWithError() {
        mockAPIClient.cannedResponseError = NSError(domain: "", code: 0, userInfo: nil)

        let dummyRequest = BTPayPalRequest(amount: "1")
        let expectation = self.expectation(description: "Checkout fails with error")
        payPalDriver.requestOneTimePayment(dummyRequest) { (_, error) -> Void in
            XCTAssertEqual(error! as NSError, self.mockAPIClient.cannedResponseError!)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 1)
    }

    func testCheckout_whenDisplayNameIsNotSet_doesNotPostPaymentResourceWithBrandName() {
        let request = BTPayPalRequest(amount: "1")
        request.currencyCode = "GBP"

        XCTAssertNil(request.displayName)

        payPalDriver.requestOneTimePayment(request) { _,_  -> Void in }

        XCTAssertEqual("v1/paypal_hermes/create_payment_resource", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }

        guard let experienceProfile = lastPostParameters["experience_profile"] as? [String:Any] else {
            XCTFail()
            return
        }
        XCTAssertFalse(experienceProfile.keys.contains("brand_name"))
    }

    func testCheckout_whenDisplayNameIsSet_postsPaymentResourceWithDisplayName() {
        let merchantName = "My Random Merchant Name"

        let request = BTPayPalRequest(amount: "1")
        request.currencyCode = "GBP"
        request.displayName = merchantName

        payPalDriver.requestOneTimePayment(request) { _,_  -> Void in }

        XCTAssertEqual("v1/paypal_hermes/create_payment_resource", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }

        guard let experienceProfile = lastPostParameters["experience_profile"] as? [String:Any] else {
            XCTFail()
            return
        }
        XCTAssertEqual(experienceProfile["brand_name"] as? String, merchantName)
    }

    func testCheckout_whenMerchantAccountIdIsSet_postsPaymentResourceWithMerchantAccountId() {
        let merchantAccountId = "alternate-merchant-account-id"

        let request = BTPayPalRequest(amount: "1")
        request.currencyCode = "GBP"
        request.merchantAccountId = merchantAccountId

        payPalDriver.requestOneTimePayment(request) { _,_  -> Void in }

        XCTAssertEqual("v1/paypal_hermes/create_payment_resource", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }

        XCTAssertEqual(lastPostParameters["merchant_account_id"] as? String, merchantAccountId)
    }

    func testCheckout_whenDisplayNameIsSetInConfiguration_postsPaymentResourceWithConfigurationBrandName() {
        let merchantName = "My Random Merchant Name"

        mockAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true,
            "paypal": [
                "displayName": merchantName
            ]
        ])
        let request = BTPayPalRequest(amount: "1")
        request.currencyCode = "GBP"
        request.displayName = merchantName

        payPalDriver.requestOneTimePayment(request) { _,_  -> Void in }

        XCTAssertEqual("v1/paypal_hermes/create_payment_resource", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }

        guard let experienceProfile = lastPostParameters["experience_profile"] as? [String:Any] else {
            XCTFail()
            return
        }
        XCTAssertEqual(experienceProfile["brand_name"] as? String, merchantName)
    }

    func testCheckout_whenRemoteConfigurationFetchSucceeds_postsPaymentResourceWithShippingAddress() {
        let request = BTPayPalRequest(amount: "1")
        request.currencyCode = "GBP"
        let address : BTPostalAddress = BTPostalAddress()
        address.streetAddress = "1234 Fake St."
        address.extendedAddress = "Apt. 0"
        address.region = "CA"
        address.locality = "Oakland"
        address.countryCodeAlpha2 = "US"
        address.postalCode = "12345"
        request.shippingAddressOverride = address

        payPalDriver.requestOneTimePayment(request) { _,_  -> Void in }

        XCTAssertEqual("v1/paypal_hermes/create_payment_resource", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        guard let experienceProfile = lastPostParameters["experience_profile"] as? [String:Any] else {
            XCTFail()
            return
        }
        XCTAssertEqual(lastPostParameters["offer_paypal_credit"] as? Bool, false)
        XCTAssertEqual(lastPostParameters["offer_pay_later"] as? Bool, false)
        XCTAssertEqual(experienceProfile["address_override"] as? Bool, true)
        XCTAssertEqual(lastPostParameters["line1"] as? String, "1234 Fake St.")
        XCTAssertEqual(lastPostParameters["line2"] as? String, "Apt. 0")
        XCTAssertEqual(lastPostParameters["city"] as? String, "Oakland")
        XCTAssertEqual(lastPostParameters["state"] as? String, "CA")
        XCTAssertEqual(lastPostParameters["postal_code"] as? String, "12345")
        XCTAssertEqual(lastPostParameters["country_code"] as? String, "US")
    }

    func testCheckout_whenRemoteConfigurationFetchSucceeds_postsPaymentResourceWithPartialShippingAddress() {
        let request = BTPayPalRequest(amount: "1")
        request.currencyCode = "GBP"
        let address : BTPostalAddress = BTPostalAddress()
        address.streetAddress = "1234 Fake St."
        address.region = "CA"
        address.locality = "Oakland"
        address.countryCodeAlpha2 = "US"
        address.postalCode = "12345"
        request.shippingAddressOverride = address

        payPalDriver.requestOneTimePayment(request) { _,_  -> Void in }

        XCTAssertEqual("v1/paypal_hermes/create_payment_resource", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }
        guard let experienceProfile = lastPostParameters["experience_profile"] as? [String:Any] else {
            XCTFail()
            return
        }
        XCTAssertEqual(lastPostParameters["offer_paypal_credit"] as? Bool, false)
        XCTAssertEqual(lastPostParameters["offer_pay_later"] as? Bool, false)
        XCTAssertEqual(experienceProfile["address_override"] as? Bool, true)
        XCTAssertEqual(lastPostParameters["line1"] as? String, "1234 Fake St.")
        XCTAssertNil(lastPostParameters["line2"])
        XCTAssertEqual(lastPostParameters["city"] as? String, "Oakland")
        XCTAssertEqual(lastPostParameters["state"] as? String, "CA")
        XCTAssertEqual(lastPostParameters["postal_code"] as? String, "12345")
        XCTAssertEqual(lastPostParameters["country_code"] as? String, "US")
    }

    func testCheckout_postsPaymentResourceWithShippingAddressEditable() {
        let request = BTPayPalRequest(amount: "1")
        request.currencyCode = "GBP"
        let address : BTPostalAddress = BTPostalAddress()
        request.shippingAddressOverride = address
        request.isShippingAddressEditable = true

        payPalDriver.requestOneTimePayment(request) { _,_  -> Void in }

        XCTAssertEqual("v1/paypal_hermes/create_payment_resource", mockAPIClient.lastPOSTPath)
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

    func testCheckout_whenRemoteConfigurationFetchSucceeds_postsPaymentResourceWithLineItems() {
        let request = BTPayPalRequest(amount: "1")

        let lineItem1 = BTPayPalLineItem(quantity: "2",
                                              unitAmount: "1.23",
                                              name: "itemName",
                                              kind: .debit)
        lineItem1.unitTaxAmount = "0.34"
        lineItem1.itemDescription = "itemDescription"
        lineItem1.productCode = "productCode"
        lineItem1.url = URL(string: "https://www.example.com")

        let lineItem2 = BTPayPalLineItem(quantity: "3",
                                              unitAmount: "2.34",
                                              name: "itemName2",
                                              kind: .credit)

        request.lineItems = [lineItem1, lineItem2]

        payPalDriver.requestOneTimePayment(request) { _,_  -> Void in }

        XCTAssertEqual("v1/paypal_hermes/create_payment_resource", mockAPIClient.lastPOSTPath)
        guard let lastPostParameters = mockAPIClient.lastPOSTParameters else {
            XCTFail()
            return
        }

        guard let lineItems = lastPostParameters["line_items"] as? [Any] else {
            XCTFail()
            return
        }

        XCTAssertEqual(lineItems.count, 2)

        guard let firstLineItem = lineItems.first as? [String:String] else {
            XCTFail()
            return
        }

        XCTAssertEqual(firstLineItem["quantity"], "2")
        XCTAssertEqual(firstLineItem["unit_amount"], "1.23")
        XCTAssertEqual(firstLineItem["name"], "itemName")
        XCTAssertEqual(firstLineItem["kind"], "debit")
        XCTAssertEqual(firstLineItem["unit_tax_amount"], "0.34")
        XCTAssertEqual(firstLineItem["description"], "itemDescription")
        XCTAssertEqual(firstLineItem["product_code"], "productCode")
        XCTAssertEqual(firstLineItem["url"], "https://www.example.com")

        guard let secondLineItem = lineItems[1] as? [String:String] else {
            XCTFail()
            return
        }

        XCTAssertEqual(secondLineItem["kind"], "credit")
    }

    // MARK: - PayPal approval URL to present in browser

    func testCheckout_whenUserActionIsNotSet_approvalUrlIsNotModified() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": [
                "redirectUrl": "https://www.paypal.com/checkout?EC-Token=EC-Random-Value"
            ]
        ])

        let request = BTPayPalRequest(amount: "1")
        payPalDriver.requestOneTimePayment(request) { (_, _) in }

        XCTAssertEqual("https://www.paypal.com/checkout?EC-Token=EC-Random-Value", payPalDriver.approvalUrl.absoluteString)
    }

    func testCheckout_whenUserActionIsSetToDefault_approvalUrlIsNotModified() {
        mockAPIClient.cannedResponseBody = BTJSON(value: [
            "paymentResource": [
                "redirectUrl": "https://www.paypal.com/checkout?EC-Token=EC-Random-Value"
            ]
        ])

        let request = BTPayPalRequest(amount: "1")
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

        let request = BTPayPalRequest(amount: "1")
        request.userAction = BTPayPalRequestUserAction.commit

        payPalDriver.requestOneTimePayment(request) { (_, _) in }

        XCTAssertEqual("https://www.paypal.com/checkout?EC-Token=EC-Random-Value&useraction=commit", payPalDriver.approvalUrl.absoluteString)
    }

    // MARK: - Browser switch

    func testCheckout_whenPayPalCreditOffered_performsSwitchCorrectly() {
        let request = BTPayPalRequest(amount: "1")
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
        let request = BTPayPalRequest(amount: "1")
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
        let request = BTPayPalRequest(amount: "1")
        payPalDriver.requestOneTimePayment(request) { _,_  -> Void in }

        XCTAssertNotNil(payPalDriver.authenticationSession)
        XCTAssertTrue(payPalDriver.isAuthenticationSessionStarted)

        XCTAssertNotNil(payPalDriver.clientMetadataId)
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
        payPalDriver.payPalRequest = BTPayPalRequest(amount: "1.34")
        payPalDriver.payPalRequest.intent = .sale

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
        let merchantAccountId = "alternate-merchant-account-id"
        payPalDriver.payPalRequest = BTPayPalRequest(amount: "1.34")
        payPalDriver.payPalRequest.merchantAccountId = merchantAccountId

        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        payPalDriver.handleBrowserSwitchReturn(returnURL, paymentType: .checkout) { (_, _) in }

        XCTAssertEqual(mockAPIClient.lastPOSTPath, "/v1/payment_methods/paypal_accounts")
        let lastPostParameters = mockAPIClient.lastPOSTParameters!
        XCTAssertEqual(lastPostParameters["merchant_account_id"] as? String, merchantAccountId)
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
        payPalDriver.payPalRequest = BTPayPalRequest(amount: "1.34")

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
        payPalDriver.payPalRequest = BTPayPalRequest(amount: "1.34")

        let returnURL = URL(string: "bar://onetouch/v1/success?token=hermes_token")!
        payPalDriver.handleBrowserSwitchReturn(returnURL, paymentType: .checkout) { (_, _) in }

        XCTAssertTrue(mockAPIClient.postedAnalyticsEvents.contains("ios.paypal-single-payment.credit.accepted"))
    }

    func testCheckout_whenBrowserSwitchSucceeds_makesDelegateCallback() {
        let delegate = MockAppContextSwitchDelegate()
        delegate.appContextDidReturnExpectation = expectation(description: "appContextDidReturn called")
        payPalDriver.appContextSwitchDelegate = delegate

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
                XCTAssertEqual(tokenizedPayPalAccount!.payerId, "FAKE-PAYER-ID")
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
        XCTAssertEqual(metaParameters["sessionId"] as? String, mockAPIClient.metadata.sessionId)
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
