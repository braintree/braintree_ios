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

        let parameters = request.parameters(with: configuration)

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

        let parameters = request.parameters(with: configuration)

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
        let parameters = request.parameters(with: configuration)

        XCTAssertEqual(parameters["currency_iso_code"] as? String, "currency-code")
    }

    func testParametersWithConfiguration_whenRequestBillingAgreementIsFalse_andBillingAgreementDescriptionIsSet_doesNotReturnDescription() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        request.billingAgreementDescription = "description"

        let parameters = request.parameters(with: configuration)

        XCTAssertNil(parameters["request_billing_agreement"])
        XCTAssertNil(parameters["billing_agreement_details"])
    }
    
    func testParametersWithConfiguration_whenUserAuthenticationEmailNotSet_doesNotSetPayerEmailInRequest() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        request.userAuthenticationEmail = ""
        
        let parameters = request.parameters(with: configuration)
        
        XCTAssertNil(parameters["payer_email"])
    }
}
