import XCTest
@testable import BraintreeCore
@testable import BraintreePayPal
@testable import BraintreeTestShared

class BTPayPalVaultRequest_Tests: XCTestCase {

    private var configuration: BTConfiguration!

    override func setUp() {
        super.setUp()
        let json = BTJSON(value: [
            "paypalEnabled": true,
            "paypal": ["environment": "offline"]
        ] as [String: Any])

        configuration = BTConfiguration(json: json)
    }

    // MARK: - hermesPath

    func testHermesPath_returnCorrectPath() {
        let request = BTPayPalVaultRequest()
        XCTAssertEqual(request.hermesPath, "v1/paypal_hermes/setup_billing_agreement")
    }

    // MARK: - paymentType

    func testPaymentType_returnsVault() {
        let request = BTPayPalVaultRequest()
        XCTAssertEqual(request.paymentType, .vault)
    }
    
    // MARK: - userActionAsString

    func testUserActionAsString_whenUserActionNotSpecified_returnsEmptyString() {
        let request = BTPayPalVaultRequest()
        XCTAssertEqual(request.userAction.stringValue, "")
    }

    func testUserActionAsString_whenUserActionIsDefault_returnsEmptyString() {
        let request = BTPayPalVaultRequest()
        request.userAction = .none
        XCTAssertEqual(request.userAction.stringValue, "")
    }

    func testUserActionAsString_whenUserActionIsSetupNow_returnsSetupNow() {
        let request = BTPayPalVaultRequest()
        request.userAction = .setupNow
        XCTAssertEqual(request.userAction.stringValue, "setup_now")
    }

    // MARK: - parametersWithConfiguration

    func testParametersWithConfiguration_returnsAllParams() {
        let request = BTPayPalVaultRequest()
        request.billingAgreementDescription = "desc"

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
        request.offerCredit = true
        request.userAuthenticationEmail = "fake@email.com"
        request.userPhoneNumber = BTPayPalPhoneNumber(countryCode: "1", nationalNumber: "4087463271")

        guard let parameters = try? request.encodedPostBodyWith(configuration: configuration).toDictionary() else {
            XCTFail()
            return
        }

        XCTAssertEqual(parameters["description"] as? String, "desc")
        XCTAssertEqual(parameters["offer_paypal_credit"] as? Bool, true)
        XCTAssertEqual(parameters["payer_email"] as? String, "fake@email.com")
        XCTAssertNil(parameters["launch_paypal_app"])
        XCTAssertNil(parameters["os_version"])
        XCTAssertNil(parameters["os_type"])
        XCTAssertNil(parameters["merchant_app_return_url"])
        
        guard let userPhoneNumberDetails = parameters["payer_phone"] as? [String: String] else {
            XCTFail()
            return
        }
        XCTAssertEqual(userPhoneNumberDetails["country_code"], "1")
        XCTAssertEqual(userPhoneNumberDetails["national_number"], "4087463271")
        
        guard let shippingParams = parameters["shipping_address"] as? [String:String] else { XCTFail(); return }

        XCTAssertEqual(shippingParams["line1"], "123 Main")
        XCTAssertEqual(shippingParams["line2"], "Unit 1")
        XCTAssertEqual(shippingParams["city"], "Chicago")
        XCTAssertEqual(shippingParams["state"], "IL")
        XCTAssertEqual(shippingParams["postal_code"], "11111")
        XCTAssertEqual(shippingParams["country_code"], "US")
        XCTAssertEqual(shippingParams["recipient_name"], "Recipient")
    }
    
    func testParameters_withEnablePayPalAppSwitchTrue_returnsAllParams() {
        let request = BTPayPalVaultRequest(
            enablePayPalAppSwitch: true,
            userAuthenticationEmail: "sally@gmail.com"
        )
        
        guard let parameters = try? request.encodedPostBodyWith(configuration: configuration, isPayPalAppInstalled: true, universalLink: URL(string: "some-url")!).toDictionary() else {
            XCTFail()
            return
        }

        XCTAssertEqual(parameters["launch_paypal_app"] as? Bool, true)
        XCTAssertTrue((parameters["os_version"] as! String).matches("\\d+\\.\\d+"))
        XCTAssertTrue((parameters["os_type"] as! String).matches("iOS|iPadOS"))
        XCTAssertEqual(parameters["merchant_app_return_url"] as? String, "some-url")
    }
    
    func testParametersWithConfiguration_setsAppSwitchParameters_withoutUserAuthenticationEmail() {
        let request = BTPayPalVaultRequest(
            enablePayPalAppSwitch: true
        )
        
        guard let parameters = try? request.encodedPostBodyWith(configuration: configuration, isPayPalAppInstalled: true, universalLink:  URL(string: "some-merchant-url")!)
            .toDictionary() else {
                XCTFail()
                return
            }
        
        XCTAssertNil(parameters["payer_email"])
        XCTAssertEqual(parameters["launch_paypal_app"] as? Bool, true)
        XCTAssertTrue((parameters["os_version"] as! String).matches("\\d+\\.\\d+"))
        XCTAssertTrue((parameters["os_type"] as! String).matches("iOS|iPadOS"))
        XCTAssertEqual(parameters["merchant_app_return_url"] as? String, "some-merchant-url")
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
        
        let request = BTPayPalVaultRequest(recurringBillingDetails: recurringBillingDetails, recurringBillingPlanType: .subscription)
        
        guard let parameters = try? request.encodedPostBodyWith(configuration: configuration, universalLink: URL(string: "some-url")!).toDictionary() else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(parameters["plan_type"] as! String, "SUBSCRIPTION")
        
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

        guard let billingCycles = planMetadata["billing_cycles"] as? [[String:Any]] else { XCTFail(); return }
        XCTAssertEqual(billingCycles[0]["billing_frequency"] as! Int, 13)
        XCTAssertEqual(billingCycles[0]["billing_frequency_unit"] as! String, "MONTH")
        XCTAssertEqual(billingCycles[0]["number_of_executions"] as! Int, 12)
        XCTAssertEqual(billingCycles[0]["sequence"] as! Int, 9)
        XCTAssertEqual(billingCycles[0]["start_date"] as! String, "test-date")
        XCTAssertFalse(billingCycles[0]["trial"] as! Bool)
        
        guard let pricingScheme = billingCycles[0]["pricing_scheme"] as? [String:String] else { XCTFail(); return }
        XCTAssertEqual(pricingScheme["pricing_model"], "AUTO_RELOAD")
        XCTAssertEqual(pricingScheme["price"], "test-price")
        XCTAssertEqual(pricingScheme["reload_threshold_amount"], "test-threshold")
    }

    func testParametersWithConfiguration_returnsAllBaseParams() {
        let request = BTPayPalVaultRequest()
        request.isShippingAddressRequired = true
        request.displayName = "Display Name"
        request.landingPageType = .login
        request.localeCode = .en_US
        request.riskCorrelationID = "123-correlation-id"
        request.merchantAccountID = "merchant-account-id"
        request.isShippingAddressEditable = true
        
        let lineItem = BTPayPalLineItem(quantity: "1", unitAmount: "1", name: "item", kind: .credit)
        lineItem.imageURL = URL(string: "http://example/image.jpg")
        lineItem.upcCode = "upc-code"
        lineItem.upcType = .UPC_A
        request.lineItems = [lineItem]
        
        guard let parameters = try? request.encodedPostBodyWith(configuration: configuration).toDictionary() else {
            XCTFail()
            return
        }
        
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
    }

    func testParametersWithConfiguration_whenShippingAddressIsRequiredNotSet_returnsNoShippingTrue() {
        let request = BTPayPalVaultRequest()
        // no_shipping = true should be the default.

        guard let parameters = try? request.encodedPostBodyWith(configuration: configuration).toDictionary() else {
            XCTFail()
            return
        }
        
        guard let experienceProfile = parameters["experience_profile"] as? [String : Any] else { XCTFail(); return }

        XCTAssertEqual(experienceProfile["no_shipping"] as? Bool, true)
    }

    func testParametersWithConfiguration_whenShippingAddressIsRequiredIsTrue_returnsNoShippingFalse() {
        let request = BTPayPalVaultRequest()
        request.isShippingAddressRequired = true

        guard let parameters = try? request.encodedPostBodyWith(configuration: configuration).toDictionary() else {
            XCTFail()
            return
        }
        
        guard let experienceProfile = parameters["experience_profile"] as? [String:Any] else { XCTFail(); return }
        XCTAssertEqual(experienceProfile["no_shipping"] as? Bool, false)
    }
    
    // MARK: - landingPageTypeAsString

    func testLandingPageTypeAsString_whenLandingPageTypeIsNotSpecified_returnNil() {
        let request = BTPayPalVaultRequest()
        XCTAssertNil(request.landingPageType?.stringValue)
    }

    func testLandingPageTypeAsString_whenLandingPageTypeIsBilling_returnsBilling() {
        let request = BTPayPalVaultRequest()
        request.landingPageType = .billing
        XCTAssertEqual(request.landingPageType?.stringValue, "billing")
    }

    func testLandingPageTypeAsString_whenLandingPageTypeIsLogin_returnsLogin() {
        let request = BTPayPalVaultRequest()
        request.landingPageType = .login
        XCTAssertEqual(request.landingPageType?.stringValue, "login")
    }
    
    // MARK: - enablePayPalAppSwitch
    
    func testEnablePayPalAppSwitch_whenInitialized_setsAllRequiredValues() {
        let request = BTPayPalVaultRequest(
            enablePayPalAppSwitch: true,
            userAuthenticationEmail: "fake@gmail.com"
        )
        
        XCTAssertEqual(request.userAuthenticationEmail, "fake@gmail.com")
        XCTAssertTrue(request.enablePayPalAppSwitch)
    }
    
    func testParameters_enableAppSwitch_withRecurringBillingDetails_returnsAllParams() {
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
        
        let request = BTPayPalVaultRequest(enablePayPalAppSwitch: true)
        request.recurringBillingDetails = recurringBillingDetails
        request.recurringBillingPlanType = .subscription
                
        guard let parameters = try? request.encodedPostBodyWith(configuration: configuration, isPayPalAppInstalled: true, universalLink: URL(string: "some-url")).toDictionary() else {
            XCTFail()
            return
        }
        
        guard let planTypeParameter = parameters["plan_type"] as? String else { XCTFail(); return }
        XCTAssertEqual(planTypeParameter, "SUBSCRIPTION")
        
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

        guard let billingCycles = planMetadata["billing_cycles"] as? [[String:Any]] else { XCTFail(); return }
        XCTAssertEqual(billingCycles[0]["billing_frequency"] as! Int, 13)
        XCTAssertEqual(billingCycles[0]["billing_frequency_unit"] as! String, "MONTH")
        XCTAssertEqual(billingCycles[0]["number_of_executions"] as! Int, 12)
        XCTAssertEqual(billingCycles[0]["sequence"] as! Int, 9)
        XCTAssertEqual(billingCycles[0]["start_date"] as! String, "test-date")
        XCTAssertFalse(billingCycles[0]["trial"] as! Bool)
        
        guard let pricingScheme = billingCycles[0]["pricing_scheme"] as? [String:String] else { XCTFail(); return }
        XCTAssertEqual(pricingScheme["pricing_model"], "AUTO_RELOAD")
        XCTAssertEqual(pricingScheme["price"], "test-price")
        XCTAssertEqual(pricingScheme["reload_threshold_amount"], "test-threshold")
    }
}
