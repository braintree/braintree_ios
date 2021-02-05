import XCTest
import BraintreePayPal

class BTPayPalRequest_Tests: XCTestCase {

    private var configuration: BTConfiguration!

    override func setUp() {
        super.setUp()
        let json = BTJSON(value: [
            "paypalEnabled": true,
            "paypal": [
                "environment": "offline"
            ]
        ])

        configuration = BTConfiguration(json: json)
    }

    // MARK: - parametersWithConfiguration (checkout flow)

    func testParametersWithConfiguration_whenIsNotBillingAgreement_returnsAllParams() {
        let request = BTPayPalRequest(amount: "1")
        request.intent = .sale
        request.offerCredit = true
        request.offerPayLater = true
        request.isShippingAddressRequired = true
        request.displayName = "Display Name"
        request.landingPageType = .login
        request.localeCode = "locale-code"
        request.merchantAccountId = "merchant-account-id"
        request.currencyCode = "currency-code"

        let shippingAddress = BTPostalAddress()
        shippingAddress.streetAddress = "123 Main"
        shippingAddress.extendedAddress = "Unit 1"
        shippingAddress.locality = "Chicago"
        shippingAddress.region = "IL"
        shippingAddress.postalCode = "11111"
        shippingAddress.countryCodeAlpha2 = "US"
        shippingAddress.recipientName = "Recipient"
        request.shippingAddressOverride = shippingAddress
        request.isShippingAddressEditable = true

        request.lineItems = [BTPayPalLineItem(quantity: "1", unitAmount: "1", name: "item", kind: .credit)]

        let parameters = request.parameters(with: configuration, isBillingAgreement: false)
        guard let experienceProfile = parameters["experience_profile"] as? [String : Any] else { XCTFail(); return }

        XCTAssertEqual(parameters["intent"] as? String, "sale")
        XCTAssertEqual(parameters["amount"] as? String, "1")
        XCTAssertEqual(parameters["offer_paypal_credit"] as? Bool, true)
        XCTAssertEqual(parameters["offer_pay_later"] as? Bool, true)
        XCTAssertEqual(experienceProfile["no_shipping"] as? Bool, false)
        XCTAssertEqual(experienceProfile["brand_name"] as? String, "Display Name")
        XCTAssertEqual(experienceProfile["landing_page_type"] as? String, "login")
        XCTAssertEqual(experienceProfile["locale_code"] as? String, "locale-code")
        XCTAssertEqual(parameters["merchant_account_id"] as? String, "merchant-account-id")
        XCTAssertEqual(parameters["currency_iso_code"] as? String, "currency-code")
        XCTAssertEqual(experienceProfile["address_override"] as? Bool, false)
        XCTAssertEqual(parameters["line1"] as? String, "123 Main")
        XCTAssertEqual(parameters["line2"] as? String, "Unit 1")
        XCTAssertEqual(parameters["city"] as? String, "Chicago")
        XCTAssertEqual(parameters["state"] as? String, "IL")
        XCTAssertEqual(parameters["postal_code"] as? String, "11111")
        XCTAssertEqual(parameters["country_code"] as? String, "US")
        XCTAssertEqual(parameters["recipient_name"] as? String, "Recipient")
        XCTAssertEqual(parameters["line_items"] as? [[String : String]], [["quantity" : "1",
                                                                                   "unit_amount": "1",
                                                                                   "name": "item",
                                                                                   "kind": "credit"]])

        XCTAssertEqual(parameters["return_url"] as? String, "sdk.ios.braintree://onetouch/v1/success")
        XCTAssertEqual(parameters["cancel_url"] as? String, "sdk.ios.braintree://onetouch/v1/cancel")
    }

    func testParametersWithConfiguration_whenIsNotBillingAgreement_andCurrencyCodeNotSet_usesConfigCurrencyCode() {
        let json = BTJSON(value: [
            "paypalEnabled": true,
            "paypal": [
                "currencyIsoCode": "currency-code"
            ]
        ])

        configuration = BTConfiguration(json: json)

        let request = BTPayPalRequest(amount: "1")
        let parameters = request.parameters(with: configuration, isBillingAgreement: false)

        XCTAssertEqual(parameters["currency_iso_code"] as? String, "currency-code")
    }

    func testParametersWithConfiguration_whenIsNotBillingAgreement_andShippingAddressIsRequiredNotSet_returnsNoShippingTrue() {
        let request = BTPayPalRequest(amount: "1")
        request.currencyCode = "GBP"
        // no_shipping = true should be the default.

        let parameters = request.parameters(with: configuration, isBillingAgreement: false)
        guard let experienceProfile = parameters["experience_profile"] as? [String : Any] else { XCTFail(); return }

        XCTAssertEqual(experienceProfile["no_shipping"] as? Bool, true)
    }

    func testParametersWithConfiguration_whenIsNotBillingAgreement_andShippingAddressIsRequiredIsTrue_returnsNoShippingFalse() {
        let request = BTPayPalRequest(amount: "1")
        request.currencyCode = "GBP"
        request.isShippingAddressRequired = true

        let parameters = request.parameters(with: configuration, isBillingAgreement: false)
        guard let experienceProfile = parameters["experience_profile"] as? [String:Any] else { XCTFail(); return }
        XCTAssertEqual(experienceProfile["no_shipping"] as? Bool, false)
    }

    func testParametersWithConfiguration_whenIsNotBillingAgreement_andIntentIsNotSpecified_returnsAuthorizeIntent() {
        let request = BTPayPalRequest(amount: "1")
        let parameters = request.parameters(with: configuration, isBillingAgreement: false)
        XCTAssertEqual(parameters["intent"] as? String, "authorize")
    }

    func testParametersWithConfiguration_whenIsNotBillingAgreement_andIntentIsSetToAuthorize_returnsAuthorizeIntent() {
        let request = BTPayPalRequest(amount: "1")
        request.intent = .authorize
        let parameters = request.parameters(with: configuration, isBillingAgreement: false)
        XCTAssertEqual(parameters["intent"] as? String, "authorize")
    }

    func testParametersWithConfiguration_whenIsNotBillingAgreement_andIntentIsSetToSale_returnsSaleIntent() {
        let request = BTPayPalRequest(amount: "1")
        request.intent = .sale
        let parameters = request.parameters(with: configuration, isBillingAgreement: false)
        XCTAssertEqual(parameters["intent"] as? String, "sale")
    }

    func testParametersWithConfiguration_whenIsNotBillingAgreement_andIntentIsSetToOrder_returnsOrderIntent() {
        let request = BTPayPalRequest(amount: "1")
        request.intent = .order
        let parameters = request.parameters(with: configuration, isBillingAgreement: false)
        XCTAssertEqual(parameters["intent"] as? String, "order")
    }

    func testParametersWithConfiguration_whenIsNotBillingAgreement_andLandingPageTypeIsNotSpecified_doesNotReturnLandingPageType() {
        let request = BTPayPalRequest(amount: "1")

        let parameters = request.parameters(with: configuration, isBillingAgreement: false)
        guard let experienceProfile = parameters["experience_profile"] as? [String : Any] else { XCTFail(); return }
        XCTAssertNil(experienceProfile["landing_page_type"])
    }

    func testParametersWithConfiguration_whenIsNotBillingAgreement_andLandingPageTypeIsBilling_returnsBillingLandingPageType() {
        let request = BTPayPalRequest(amount: "1")
        request.landingPageType = .billing

        let parameters = request.parameters(with: configuration, isBillingAgreement: false)
        guard let experienceProfile = parameters["experience_profile"] as? [String : Any] else { XCTFail(); return }
        XCTAssertEqual(experienceProfile["landing_page_type"] as? String, "billing")
    }

    func testParametersWithConfiguration_whenIsNotBillingAgreement_andLandingPageTypeIsLogin_returnsLoginLandingPageType() {
        let request = BTPayPalRequest(amount: "1")
        request.landingPageType = .login

        let parameters = request.parameters(with: configuration, isBillingAgreement: false)
        guard let experienceProfile = parameters["experience_profile"] as? [String : Any] else { XCTFail(); return }
        XCTAssertEqual(experienceProfile["landing_page_type"] as? String, "login")
    }

    // MARK: - parametersWithConfiguration (vault flow)

    func testParametersWithConfiguration_whenIsBillingAgreement_returnsAllParams() {
        let request = BTPayPalRequest()
        request.billingAgreementDescription = "description"
        request.offerCredit = true
        request.offerPayLater = true
        request.isShippingAddressRequired = true
        request.displayName = "Display Name"
        request.landingPageType = .login
        request.localeCode = "locale-code"
        request.merchantAccountId = "merchant-account-id"

        let shippingAddressOverride = BTPostalAddress()
        shippingAddressOverride.streetAddress = "123 Main"
        shippingAddressOverride.extendedAddress = "Unit 1"
        shippingAddressOverride.locality = "Chicago"
        shippingAddressOverride.region = "IL"
        shippingAddressOverride.postalCode = "11111"
        shippingAddressOverride.countryCodeAlpha2 = "US"
        shippingAddressOverride.recipientName = "Recipient"
        request.shippingAddressOverride = shippingAddressOverride
        request.isShippingAddressEditable = true

        request.lineItems = [BTPayPalLineItem(quantity: "1", unitAmount: "1", name: "item", kind: .credit)]

        let parameters = request.parameters(with: configuration, isBillingAgreement: true)
        guard let experienceProfile = parameters["experience_profile"] as? [String : Any] else { XCTFail(); return }
        guard let shippingAddress = parameters["shipping_address"] as? [String : String] else { XCTFail(); return }

        XCTAssertEqual(parameters["description"] as? String, "description")
        XCTAssertEqual(parameters["offer_paypal_credit"] as? Bool, true)
        XCTAssertEqual(parameters["offer_pay_later"] as? Bool, true)
        XCTAssertEqual(experienceProfile["no_shipping"] as? Bool, false)
        XCTAssertEqual(experienceProfile["brand_name"] as? String, "Display Name")
        XCTAssertEqual(experienceProfile["landing_page_type"] as? String, "login")
        XCTAssertEqual(experienceProfile["locale_code"] as? String, "locale-code")
        XCTAssertEqual(parameters["merchant_account_id"] as? String, "merchant-account-id")
        XCTAssertEqual(experienceProfile["address_override"] as? Bool, false)
        XCTAssertEqual(shippingAddress["line1"], "123 Main")
        XCTAssertEqual(shippingAddress["line2"], "Unit 1")
        XCTAssertEqual(shippingAddress["city"], "Chicago")
        XCTAssertEqual(shippingAddress["state"], "IL")
        XCTAssertEqual(shippingAddress["postal_code"], "11111")
        XCTAssertEqual(shippingAddress["country_code"], "US")
        XCTAssertEqual(shippingAddress["recipient_name"], "Recipient")
        XCTAssertEqual(parameters["line_items"] as? [[String : String]], [["quantity" : "1",
                                                                                   "unit_amount": "1",
                                                                                   "name": "item",
                                                                                   "kind": "credit"]])

        XCTAssertEqual(parameters["return_url"] as? String, "sdk.ios.braintree://onetouch/v1/success")
        XCTAssertEqual(parameters["cancel_url"] as? String, "sdk.ios.braintree://onetouch/v1/cancel")
    }

    func testParametersWithConfiguration_whenIsBillingAgreement_doesNotReturnIntent() {
        let request = BTPayPalRequest()
        request.intent = .authorize

        let parameters = request.parameters(with: configuration, isBillingAgreement: true)

        XCTAssertNil(parameters["intent"])
    }

    func testParametersWithConfiguration_whenIsBillingAgreement_andConfigurationHasCurrency_doesNotReturnCurrency() {
        let json = BTJSON(value: [
            "paypalEnabled": true,
            "paypal": [
                "environment": "offline",
                "currencyIsoCode": "GBP",
            ] ])

        configuration = BTConfiguration(json: json)

        let request = BTPayPalRequest()

        let parameters = request.parameters(with: configuration, isBillingAgreement: true)

        XCTAssertNil(parameters["currency_iso_code"])
    }

    func testParametersWithConfiguration_whenIsBillingAgreement_andRequestHasCurrency_doesNotReturnCurrency() {
        let request = BTPayPalRequest()
        request.currencyCode = "GBP"

        let parameters = request.parameters(with: configuration, isBillingAgreement: true)

        XCTAssertNil(parameters["currency_iso_code"])
        XCTAssertNil(parameters["intent"])
    }
}
