import XCTest
@testable import BraintreeCore
@testable import BraintreePayPal

class BTPayPalCheckoutRequest_Tests: XCTestCase {

    private var configuration: BTConfiguration!

    override func setUp() {
        super.setUp()
        let json = BTJSON(value: [
            "paypalEnabled": true,
            "paypal": [
                "environment": "offline"
            ]
        ] as [String: Any])

        configuration = BTConfiguration(json: json)
    }

    // MARK: - hermesPath

    func testHermesPath_returnCorrectPath() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        XCTAssertEqual(request.hermesPath, "v1/paypal_hermes/create_payment_resource")
    }

    // MARK: - paymentType

    func testPaymentType_returnCheckout() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        XCTAssertEqual(request.paymentType, .checkout)
    }

    // MARK: - intentAsString

    func testIntentAsString_whenIntentIsNotSpecified_returnsAuthorize() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        XCTAssertEqual(request.intent.stringValue, "authorize")
    }

    func testIntentAsString_whenIntentIsAuthorize_returnsAuthorize() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        request.intent = .authorize
        XCTAssertEqual(request.intent.stringValue, "authorize")
    }

    func testIntentAsString_whenIntentIsSale_returnsSale() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        request.intent = .sale
        XCTAssertEqual(request.intent.stringValue, "sale")
    }

    func testIntentAsString_whenIntentIsOrder_returnsOrder() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        request.intent = .order
        XCTAssertEqual(request.intent.stringValue, "order")
    }

    // MARK: - userActionAsString

    func testUserActionAsString_whenUserActionNotSpecified_returnsEmptyString() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        XCTAssertEqual(request.userAction.stringValue, "")
    }

    func testUserActionAsString_whenUserActionIsDefault_returnsEmptyString() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        request.userAction = .none
        XCTAssertEqual(request.userAction.stringValue, "")
    }

    func testUserActionAsString_whenUserActionIsCommit_returnsCommit() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        request.userAction = .payNow
        XCTAssertEqual(request.userAction.stringValue, "commit")
    }

    // MARK: - parametersWithConfiguration

    func testParametersWithConfiguration_returnsAllParams() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        request.intent = .sale
        request.offerPayLater = true
        request.currencyCode = "currency-code"
        request.requestBillingAgreement = true
        request.billingAgreementDescription = "description"
        request.userAction = .payNow
        request.userAuthenticationEmail = "fake@email.com"
        request.userPhoneNumber = BTPayPalPhoneNumber(countryCode: "1", nationalNumber: "4087463271")

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

        guard let parameters = try? request.encodedPostBodyWith(configuration: configuration).toDictionary() else {
            XCTFail()
            return
        }

        XCTAssertEqual(parameters["intent"] as? String, "sale")
        XCTAssertEqual(parameters["amount"] as? String, "1")
        XCTAssertEqual(parameters["offer_pay_later"] as? Bool, true)
        XCTAssertEqual(parameters["currency_iso_code"] as? String, "currency-code")
        XCTAssertEqual(parameters["line1"] as? String, "123 Main")
        XCTAssertEqual(parameters["line2"] as? String, "Unit 1")
        XCTAssertEqual(parameters["city"] as? String, "Chicago")
        XCTAssertEqual(parameters["state"] as? String, "IL")
        XCTAssertEqual(parameters["postal_code"] as? String, "11111")
        XCTAssertEqual(parameters["country_code"] as? String, "US")
        XCTAssertEqual(parameters["recipient_name"] as? String, "Recipient")
        XCTAssertEqual(parameters["payer_email"] as? String, "fake@email.com")
        XCTAssertEqual(parameters["request_billing_agreement"] as? Bool, true)
        
        guard let userPhoneNumberDetails = parameters["payer_phone"] as? [String: String] else {
            XCTFail()
            return
        }
        XCTAssertEqual(userPhoneNumberDetails["country_code"], "1")
        XCTAssertEqual(userPhoneNumberDetails["national_number"], "4087463271")

        guard let billingAgreementDetails = parameters["billing_agreement_details"] as? [String : String] else {
            XCTFail()
            return
        }

        XCTAssertEqual(billingAgreementDetails["description"], "description")

        guard let experienceProfile = parameters["experience_profile"] as? [String: Any] else { XCTFail(); return }
        XCTAssertEqual(experienceProfile["user_action"] as? String, "commit")
    }

    func testParametersWithConfiguration_returnsMinimumParams() {
        let request = BTPayPalCheckoutRequest(amount: "1")

        guard let parameters = try? request.encodedPostBodyWith(configuration: configuration).toDictionary() else {
            XCTFail()
            return
        }

        XCTAssertEqual(parameters["intent"] as? String, "authorize")
        XCTAssertEqual(parameters["amount"] as? String, "1")
        XCTAssertEqual(parameters["offer_pay_later"] as? Bool, false)
    }

    func testParametersWithConfiguration_whenCurrencyCodeNotSet_usesConfigCurrencyCode() {
        let json = BTJSON(value: [
            "paypalEnabled": true,
            "paypal": ["currencyIsoCode": "currency-code"]
        ] as [String: Any])

        configuration = BTConfiguration(json: json)

        let request = BTPayPalCheckoutRequest(amount: "1")
        
        guard let parameters = try? request.encodedPostBodyWith(configuration: configuration).toDictionary() else {
            XCTFail()
            return
        }

        XCTAssertEqual(parameters["currency_iso_code"] as? String, "currency-code")
    }

    func testParametersWithConfiguration_whenRequestBillingAgreementIsFalse_andBillingAgreementDescriptionIsSet_doesNotReturnDescription() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        request.billingAgreementDescription = "description"

        guard let parameters = try? request.encodedPostBodyWith(configuration: configuration).toDictionary() else {
            XCTFail()
            return
        }

        XCTAssertNil(parameters["request_billing_agreement"])
        XCTAssertNil(parameters["billing_agreement_details"])
    }
    
    func testParametersWithConfiguration_whenUserAuthenticationEmailNotSet_doesNotSetPayerEmailInRequest() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        request.userAuthenticationEmail = ""
        
        guard let parameters = try? request.encodedPostBodyWith(configuration: configuration).toDictionary() else {
            XCTFail()
            return
        }
        
        XCTAssertNil(parameters["payer_email"])
    }

    func testParametersWithConfiguration_returnsAllBaseParams() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        request.isShippingAddressRequired = true
        request.displayName = "Display Name"
        request.landingPageType = .login
        request.localeCode = .en_US
        request.riskCorrelationID = "123-correlation-id"
        request.merchantAccountID = "merchant-account-id"
        request.isShippingAddressEditable = true
        
        let lineItem = BTPayPalLineItem(
            quantity: "1",
            unitAmount: "1",
            name: "item",
            kind: .credit,
            imageURL: URL(string: "http://example/image.jpg"),
            upcCode: "upc-code",
            upcType: .UPC_A
        )
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
        let request = BTPayPalCheckoutRequest(amount: "1")
        // no_shipping = true should be the default.

        guard let parameters = try? request.encodedPostBodyWith(configuration: configuration).toDictionary() else {
            XCTFail()
            return
        }
        
        guard let experienceProfile = parameters["experience_profile"] as? [String : Any] else { XCTFail(); return }

        XCTAssertEqual(experienceProfile["no_shipping"] as? Bool, true)
    }

    func testParametersWithConfiguration_whenShippingAddressIsRequiredIsTrue_returnsNoShippingFalse() {
        let request = BTPayPalCheckoutRequest(amount: "1")
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
        let request = BTPayPalCheckoutRequest(amount: "1")
        XCTAssertNil(request.landingPageType?.stringValue)
    }

    func testLandingPageTypeAsString_whenLandingPageTypeIsBilling_returnsBilling() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        request.landingPageType = .billing
        XCTAssertEqual(request.landingPageType?.stringValue, "billing")
    }

    func testLandingPageTypeAsString_whenLandingPageTypeIsLogin_returnsLogin() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        request.landingPageType = .login
        XCTAssertEqual(request.landingPageType?.stringValue, "login")
    }
    
    func testParametersWithConfiguration__withContactInformation_setsRecipientEmailAndPhoneNumber() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        request.contactInformation = BTContactInformation(
            recipientEmail: "some@mail.com",
            recipientPhoneNumber: BTPayPalPhoneNumber(countryCode: "US", nationalNumber: "123456789")
        )
        
        guard let parameters = try? request.encodedPostBodyWith(configuration: configuration).toDictionary() else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(parameters["recipient_email"] as? String, "some@mail.com")
        let internationalPhone = parameters["international_phone"] as? [String: String]
        XCTAssertEqual(internationalPhone, ["country_code": "US", "national_number": "123456789"])
    }
    
    func testParametersWithConfiguration_whenContactInformationNotSet_doesNotSetPayerEmailAndPhoneNumberInRequest() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        
        guard let parameters = try? request.encodedPostBodyWith(configuration: configuration).toDictionary() else {
            XCTFail()
            return
        }
        
        XCTAssertNil(parameters["recipient_email"])
        XCTAssertNil(parameters["international_phone"])
    }
    
    func testParametersWithConfiguration_withContactInformationToUpdate_setsRecipientEmailAndPhoneNumber() {
        let contactInformation = BTContactInformation(
            recipientEmail: "some@mail.com",
            recipientPhoneNumber: BTPayPalPhoneNumber(countryCode: "US", nationalNumber: "123456789")
        )
        let request = BTPayPalCheckoutRequest(amount: "1", contactInformation: contactInformation, contactPreference: .updateContactInformation)
        
        guard let parameters = try? request.encodedPostBodyWith(configuration: configuration).toDictionary() else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(parameters["contact_preference"] as? String, "UPDATE_CONTACT_INFO")
        
        XCTAssertEqual(parameters["recipient_email"] as? String, "some@mail.com")
        let internationalPhone = parameters["international_phone"] as? [String: String]
        XCTAssertEqual(internationalPhone, ["country_code": "US", "national_number": "123456789"])
    }
    
    func testParametersWithConfiguration_withContactInformationToRetain_setsRecipientEmailAndPhoneNumber() {
        let contactInformation = BTContactInformation(
            recipientEmail: "some@mail.com",
            recipientPhoneNumber: BTPayPalPhoneNumber(countryCode: "US", nationalNumber: "123456789")
        )
        let request = BTPayPalCheckoutRequest(amount: "1", contactInformation: contactInformation, contactPreference: .retainContactInformation)
        
        guard let parameters = try? request.encodedPostBodyWith(configuration: configuration).toDictionary() else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(parameters["contact_preference"] as? String, "RETAIN_CONTACT_INFO")
        
        XCTAssertEqual(parameters["recipient_email"] as? String, "some@mail.com")
        let internationalPhone = parameters["international_phone"] as? [String: String]
        XCTAssertEqual(internationalPhone, ["country_code": "US", "national_number": "123456789"])
    }
    
    func testParametersWithConfiguration_withContactInformationWithNoInfo_setsRecipientEmailAndPhoneNumber() {
        let contactInformation = BTContactInformation(
            recipientEmail: "some@mail.com",
            recipientPhoneNumber: BTPayPalPhoneNumber(countryCode: "US", nationalNumber: "123456789")
        )
        let request = BTPayPalCheckoutRequest(amount: "1", contactInformation: contactInformation, contactPreference: .noContactInformation)
        
        
        guard let parameters = try? request.encodedPostBodyWith(configuration: configuration).toDictionary() else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(parameters["contact_preference"] as? String, "NO_CONTACT_INFO")
        
        XCTAssertEqual(parameters["recipient_email"] as? String, "some@mail.com")
        let internationalPhone = parameters["international_phone"] as? [String: String]
        XCTAssertEqual(internationalPhone, ["country_code": "US", "national_number": "123456789"])
    }

    func testParameters_whenShippingCallbackURLNotSet_returnsParameters() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        
        XCTAssertNil(request.shippingCallbackURL)
        guard let parameters = try? request.encodedPostBodyWith(configuration: configuration).toDictionary() else {
            XCTFail()
            return
        }
        XCTAssertNil(parameters["shipping_callback_url"])
    }


    func testParameters_withShippingCallbackURL_returnsParametersWithShippingCallbackURL() {
        let request = BTPayPalCheckoutRequest(amount: "1", shippingCallbackURL: URL(string: "www.some-url.com"))
        
        XCTAssertNotNil(request.shippingCallbackURL)
        guard let parameters = try? request.encodedPostBodyWith(configuration: configuration).toDictionary() else {
            XCTFail()
            return
        }
        XCTAssertNotNil(parameters["shipping_callback_url"])
    }
    
    func testParametersWithConfiguration_setsAppSwitchParameters_WithoutUserAuthenticationEmail() {
        let request = BTPayPalCheckoutRequest(amount: "1", enablePayPalAppSwitch: true)
        
        guard let parameters = try? request.encodedPostBodyWith(configuration: configuration, isPayPalAppInstalled: true, universalLink:  URL(string: "some-url")!)
            .toDictionary() else {
                XCTFail()
                return
            }
        
        XCTAssertNil(parameters["payer_email"])
        XCTAssertEqual(parameters["launch_paypal_app"] as? Bool, true)
        XCTAssertTrue((parameters["os_version"] as! String).matches("\\d+\\.\\d+"))
        XCTAssertTrue((parameters["os_type"] as! String).matches("iOS|iPadOS"))
        XCTAssertEqual(parameters["merchant_app_return_url"] as? String, "some-url")
    }

    func testCreateRequestBody_setsAmountBreakdown() {
        let amountBreakdown = BTAmountBreakdown(
            itemTotal: "10.00",
            taxTotal: "1.00",
            shippingTotal: "2.00",
            handlingTotal: "3.00",
            insuranceTotal: "4.00",
            shippingDiscount: "1.00",
            discountTotal: "2.00"
        )

        let request = BTPayPalCheckoutRequest(amount: "1.00", amountBreakdown: amountBreakdown)
        
        guard let parameters = try? request.encodedPostBodyWith(configuration: configuration).toDictionary() else {
            XCTFail()
            return
        }
        guard let amountParameters = try? request.amountBreakdown?.toDictionary() else {
            XCTFail()
            return
        }

        guard parameters["amount_breakdown"] is [String: String] else { XCTFail(); return }
        XCTAssertEqual(amountParameters["item_total"] as? String, "10.00")
        XCTAssertEqual(amountParameters["tax_total"] as? String, "1.00")
        XCTAssertEqual(amountParameters["shipping"] as? String, "2.00")
        XCTAssertEqual(amountParameters["handling"] as? String, "3.00")
        XCTAssertEqual(amountParameters["insurance"] as? String, "4.00")
        XCTAssertEqual(amountParameters["shipping_discount"] as? String, "1.00")
        XCTAssertEqual(amountParameters["discount"] as? String, "2.00")
    }
}
