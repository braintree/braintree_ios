import XCTest
@testable import BraintreePayPalNativeCheckout
@testable import BraintreeCore
@testable import BraintreePayPal

class BTPayPalNativeCheckoutRequest_Tests: XCTestCase {

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

    func testPaymentTypeIsCheckout() {
        let checkoutRequest = BTPayPalNativeCheckoutRequest(amount: "10.00")
        XCTAssertTrue(checkoutRequest.paymentType == .checkout, "Incorrect payment type on CheckoutRequest")
    }

    func testHermesPathIsCorrect() {
        let checkoutRequest = BTPayPalNativeCheckoutRequest(amount: "10.00")
        XCTAssertEqual(checkoutRequest.hermesPath, "v1/paypal_hermes/create_payment_resource")
    }

    func testUserAuthenticationEmailReturnsNil() {
      let request = BTPayPalNativeCheckoutRequest(amount: "10.00")
        XCTAssertNil(request.userAuthenticationEmail)
    }

    func testUserAuthenticationEmailReturnsEmail() {
        let request = BTPayPalNativeCheckoutRequest(amount: "10.00", userAuthenticationEmail: "user@example.com")
        XCTAssertEqual(request.userAuthenticationEmail, "user@example.com")
    }

    func testIntentStringReturnsCorrectValue() {
        let checkoutRequest = BTPayPalNativeCheckoutRequest(amount: "10.00")
        checkoutRequest.intent = .authorize
        XCTAssertEqual(checkoutRequest.intent.stringValue, "authorize")

        checkoutRequest.intent = .order
        XCTAssertEqual(checkoutRequest.intent.stringValue, "order")

        checkoutRequest.intent = .sale
        XCTAssertEqual(checkoutRequest.intent.stringValue, "sale")
    }

    func testBaseConfigurationCorrect() throws {
        let request = BTPayPalNativeCheckoutRequest(amount: "10.00")
        let lineItem = BTPayPalLineItem(
            quantity: "1",
            unitAmount: "5.00",
            name: "item one",
            kind: .credit
        )
        request.localeCode = .en_US
        request.lineItems = [lineItem]
        request.isShippingAddressRequired = true
        request.displayName = "Test Request"
        request.merchantAccountID = "Merchant Acct ID"
        request.riskCorrelationID = "Risk Correlation ID"
        request.shippingAddressOverride = BTPostalAddress()
        request.isShippingAddressEditable = true
        let baseParameters = request.parameters(with: configuration)

        let parameterLineItem = try XCTUnwrap((baseParameters["line_items"] as? [[AnyHashable: Any]])?.first)

        // Assert that the line items associated with the checkout request are included as parameters
        XCTAssertEqual(parameterLineItem["quantity"] as? String, lineItem.quantity)
        XCTAssertEqual(parameterLineItem["unit_amount"] as? String, lineItem.unitAmount)
        XCTAssertEqual(parameterLineItem["kind"] as? String, "credit")
        XCTAssertEqual(parameterLineItem["name"] as? String, lineItem.name)

        // Assert that the return and cancel URLs are correct
        XCTAssertEqual(baseParameters["cancel_url"] as? String, "sdk.ios.braintree://onetouch/v1/cancel")
        XCTAssertEqual(baseParameters["return_url"] as? String, "sdk.ios.braintree://onetouch/v1/success")
        XCTAssertEqual(baseParameters["merchant_account_id"] as? String, request.merchantAccountID)
        XCTAssertEqual(baseParameters["correlation_id"] as? String, request.riskCorrelationID)

        let profile = try XCTUnwrap(baseParameters["experience_profile"] as? [AnyHashable: Any])
        XCTAssertEqual(profile["no_shipping"] as? Bool, !request.isShippingAddressRequired)
        XCTAssertEqual(profile["brand_name"] as? String, request.displayName)
        XCTAssertEqual(profile["locale_code"] as? String, request.localeCode.stringValue)
        XCTAssertEqual(profile["address_override"] as? Bool, !request.isShippingAddressEditable)
    }

    func testParametersWithConfigurationReturnsAllParams() {
        let request = BTPayPalNativeCheckoutRequest(amount: "1")
        request.intent = .sale
        request.offerPayLater = true
        request.currencyCode = "currency-code"
        request.requestBillingAgreement = true
        request.billingAgreementDescription = "description"
        request.userAction = .payNow

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
        XCTAssertEqual(parameters["request_billing_agreement"] as? Bool, true)

        guard let billingAgreementDetails = parameters["billing_agreement_details"] as? [String : String] else {
            XCTFail()
            return
        }

        XCTAssertEqual(billingAgreementDetails["description"], "description")

        guard let experienceProfile = parameters["experience_profile"] as? [String: Any] else { XCTFail(); return }
        XCTAssertEqual(experienceProfile["user_action"] as? String, "commit")
    }

    func testVaultParameters_withShippingAddressOverrideNil_doesNotPassShippingAddress() {
        let request = BTPayPalNativeVaultRequest()
        request.shippingAddressOverride = nil

        let parameters = request.parameters(with: configuration)

        XCTAssertNil(parameters["shipping_address"])
    }
}
