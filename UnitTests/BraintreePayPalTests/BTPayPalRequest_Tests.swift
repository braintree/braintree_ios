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

    // MARK: - landingPageTypeAsString

    func testLandingPageTypeAsString_whenLandingPageTypeIsNotSpecified_returnNil() {
        let request = BTPayPalRequest()
        XCTAssertNil(request.landingPageTypeAsString)
    }

    func testLandingPageTypeAsString_whenLandingPageTypeIsBilling_returnsBilling() {
        let request = BTPayPalRequest()
        request.landingPageType = .billing
        XCTAssertEqual(request.landingPageTypeAsString, "billing")
    }

    func testLandingPageTypeAsString_whenLandingPageTypeIsLogin_returnsLogin() {
        let request = BTPayPalRequest()
        request.landingPageType = .login
        XCTAssertEqual(request.landingPageTypeAsString, "login")
    }

    // MARK: - parametersWithConfiguration

    func testParametersWithConfiguration_whenIsBillingAgreement_returnsAllParams() {
        let request = BTPayPalRequest()
        request.billingAgreementDescription = "description"
        request.offerCredit = true
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

    func testParametersWithConfiguration_whenShippingAddressIsRequiredNotSet_returnsNoShippingTrue() {
        let request = BTPayPalRequest()
        // no_shipping = true should be the default.

        let parameters = request.parameters(with: configuration, isBillingAgreement: false)
        guard let experienceProfile = parameters["experience_profile"] as? [String : Any] else { XCTFail(); return }

        XCTAssertEqual(experienceProfile["no_shipping"] as? Bool, true)
    }

    func testParametersWithConfiguration_whenShippingAddressIsRequiredIsTrue_returnsNoShippingFalse() {
        let request = BTPayPalRequest()
        request.isShippingAddressRequired = true

        let parameters = request.parameters(with: configuration, isBillingAgreement: false)
        guard let experienceProfile = parameters["experience_profile"] as? [String:Any] else { XCTFail(); return }
        XCTAssertEqual(experienceProfile["no_shipping"] as? Bool, false)
    }
}
