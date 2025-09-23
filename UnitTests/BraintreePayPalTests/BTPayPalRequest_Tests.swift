import XCTest
@testable import BraintreeCore
@testable import BraintreePayPal

class BTPayPalRequest_Tests: XCTestCase {

    private var configuration: BTConfiguration!

    override func setUp() {
        super.setUp()
        let json = BTJSON(value: [
            "paypalEnabled": true,
            "paypal": ["environment": "offline"]
        ] as [String: Any])

        configuration = BTConfiguration(json: json)
    }

    // MARK: - landingPageTypeAsString

    func testLandingPageTypeAsString_whenLandingPageTypeIsNotSpecified_returnNil() {
        let request = BTPayPalRequest(hermesPath: "hermes-test-path", paymentType: .checkout)
        XCTAssertNil(request.landingPageType.stringValue)
    }

    func testLandingPageTypeAsString_whenLandingPageTypeIsBilling_returnsBilling() {
        let request = BTPayPalRequest(hermesPath: "hermes-test-path", paymentType: .checkout)
        request.landingPageType = .billing
        XCTAssertEqual(request.landingPageType.stringValue, "billing")
    }

    func testLandingPageTypeAsString_whenLandingPageTypeIsLogin_returnsLogin() {
        let request = BTPayPalRequest(hermesPath: "hermes-test-path", paymentType: .checkout)
        request.landingPageType = .login
        XCTAssertEqual(request.landingPageType.stringValue, "login")
    }

    // MARK: - parametersWithConfiguration

    func testParametersWithConfiguration_returnsAllParams() {
        let request = BTPayPalRequest(hermesPath: "hermes-test-path", paymentType: .checkout)
        request.isShippingAddressRequired = true
        request.displayName = "Display Name"
        request.landingPageType = .login
        request.localeCode = .en_US
        request.riskCorrelationID = "123-correlation-id"
        request.merchantAccountID = "merchant-account-id"
        request.isShippingAddressEditable = true
        request.shopperSessionID = "123456"
        
        let lineItem = BTPayPalLineItem(quantity: "1", unitAmount: "1", name: "item", kind: .credit)
        lineItem.imageURL = URL(string: "http://example/image.jpg")
        lineItem.upcCode = "upc-code"
        lineItem.upcType = .UPC_A
        request.lineItems = [lineItem]

        let parameters = request.parameters(with: configuration)
        guard let experienceProfile = parameters["experience_profile"] as? [String : Any] else { XCTFail(); return }

        XCTAssertEqual(experienceProfile["no_shipping"] as? Bool, false)
        XCTAssertEqual(experienceProfile["brand_name"] as? String, "Display Name")
        XCTAssertEqual(experienceProfile["landing_page_type"] as? String, "login")
        XCTAssertEqual(experienceProfile["locale_code"] as? String, "en_US")
        XCTAssertEqual(parameters["merchant_account_id"] as? String, "merchant-account-id")
        XCTAssertEqual(parameters["correlation_id"] as? String, "123-correlation-id")
        XCTAssertEqual(experienceProfile["address_override"] as? Bool, false)
        XCTAssertEqual(parameters["line_items"] as? [[String : String]], [["quantity" : "1",
                                                                            "unit_amount": "1",
                                                                            "name": "item",
                                                                            "kind": "credit",
                                                                            "upc_code": "upc-code",
                                                                            "upc_type": "UPC-A",
                                                                            "image_url": "http://example/image.jpg"]])

        XCTAssertEqual(parameters["return_url"] as? String, "sdk.ios.braintree://onetouch/v1/success")
        XCTAssertEqual(parameters["cancel_url"] as? String, "sdk.ios.braintree://onetouch/v1/cancel")
        XCTAssertEqual(parameters["shopper_session_id"] as? String, "123456")
    }

    func testParametersWithConfiguration_whenShippingAddressIsRequiredNotSet_returnsNoShippingTrue() {
        let request = BTPayPalRequest(hermesPath: "hermes-test-path", paymentType: .checkout)
        // no_shipping = true should be the default.

        let parameters = request.parameters(with: configuration)
        guard let experienceProfile = parameters["experience_profile"] as? [String : Any] else { XCTFail(); return }

        XCTAssertEqual(experienceProfile["no_shipping"] as? Bool, true)
    }

    func testParametersWithConfiguration_whenShippingAddressIsRequiredIsTrue_returnsNoShippingFalse() {
        let request = BTPayPalRequest(hermesPath: "hermes-test-path", paymentType: .checkout)
        request.isShippingAddressRequired = true

        let parameters = request.parameters(with: configuration)
        guard let experienceProfile = parameters["experience_profile"] as? [String:Any] else { XCTFail(); return }
        XCTAssertEqual(experienceProfile["no_shipping"] as? Bool, false)
    }

    func testParameters_withRecurringBillingDetails_returnsAllParams() {
        let billingPricing = BTPayPalBillingPricing(
            pricingModel: .autoReload,
            amount: "test-price",
            reloadThresholdAmount: "test-threshold"
        )

        let billingCycle = BTPayPalBillingCycle(
            isTrial: false,
            numberOfExecutions: 12,
            interval: .month,
            intervalCount: 13,
            sequence: 9,
            startDate: "test-date",
            pricing: billingPricing
        )

        let recurringBillingDetails = BTPayPalRecurringBillingDetails(
            billingCycles: [billingCycle],
            currencyISOCode: "test-currency",
            totalAmount: "test-total",
            productName: "test-product-name",
            productDescription: "test-product-description",
            productQuantity: 1,
            oneTimeFeeAmount: "test-fee",
            shippingAmount: "test-shipping",
            productAmount: "test-price",
            taxAmount: "test-tax"
        )

        let request = BTPayPalCheckoutRequest(amount: "1.00", recurringBillingDetails: recurringBillingDetails, recurringBillingPlanType: .subscription)

        let parameters = request.parameters(with: configuration, universalLink: URL(string: "some-url"))
        XCTAssertEqual(parameters["plan_type"] as? String, "SUBSCRIPTION")

        guard let planMetadata = parameters["plan_metadata"] as? [String: Any] else { XCTFail(); return }
        XCTAssertEqual(planMetadata["currency_iso_code"] as! String, "test-currency")
        XCTAssertEqual(planMetadata["name"] as! String, "test-product-name")
        XCTAssertEqual(planMetadata["product_description"] as! String, "test-product-description")
        XCTAssertEqual(planMetadata["product_quantity"] as! Int, 1)
        XCTAssertEqual(planMetadata["one_time_fee_amount"] as! String, "test-fee")
        XCTAssertEqual(planMetadata["shipping_amount"] as! String, "test-shipping")
        XCTAssertEqual(planMetadata["product_price"] as! String, "test-price")
        XCTAssertEqual(planMetadata["tax_amount"] as! String, "test-tax")
        XCTAssertEqual(planMetadata["total_amount"] as! String, "test-total")
        
        guard let billingCycles = planMetadata["billing_cycles"] as? [[String: Any]] else { XCTFail(); return }
        XCTAssertEqual(billingCycles[0]["billing_frequency"] as! Int, 13)
        XCTAssertEqual(billingCycles[0]["billing_frequency_unit"] as! String, "MONTH")
        XCTAssertEqual(billingCycles[0]["number_of_executions"] as! Int, 12)
        XCTAssertEqual(billingCycles[0]["sequence"] as! Int, 9)
        XCTAssertEqual(billingCycles[0]["start_date"] as! String, "test-date")
        XCTAssertFalse(billingCycles[0]["trial"] as! Bool)
        
        guard let pricingScheme = billingCycles[0]["pricing_scheme"] as? [String: String] else { XCTFail(); return }
        XCTAssertEqual(pricingScheme["pricing_model"], "AUTO_RELOAD")
        XCTAssertEqual(pricingScheme["price"], "test-price")
        XCTAssertEqual(pricingScheme["reload_threshold_amount"], "test-threshold")
    }

    // MARK: - enablePayPalAppSwitch

    func testEnablePayPalAppSwitch_whenInitialized_setsAllRequiredValues() {
        let request = BTPayPalVaultRequest(
            userAuthenticationEmail: "fake@gmail.com",
            enablePayPalAppSwitch: true
        )

        XCTAssertEqual(request.userAuthenticationEmail, "fake@gmail.com")
        XCTAssertTrue(request.enablePayPalAppSwitch)
    }
}
