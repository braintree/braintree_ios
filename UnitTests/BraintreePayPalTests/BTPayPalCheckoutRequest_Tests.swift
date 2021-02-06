import XCTest
import BraintreePayPal

class BTPayPalCheckoutRequest_Tests: XCTestCase {

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

    // MARK: - intentAsString

    func testIntentAsString_whenIntentIsNotSpecified_returnsAuthorize() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        XCTAssertEqual(request.intentAsString, "authorize")
    }

    func testIntentAsString_whenIntentIsAuthorize_returnsAuthorize() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        request.intent = .authorize
        XCTAssertEqual(request.intentAsString, "authorize")
    }

    func testIntentAsString_whenIntentIsSale_returnsSale() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        request.intent = .sale
        XCTAssertEqual(request.intentAsString, "sale")
    }

    func testIntentAsString_whenIntentIsOrder_returnsOrder() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        request.intent = .order
        XCTAssertEqual(request.intentAsString, "order")
    }

    // MARK: - parametersWithConfiguration

    func testParametersWithConfiguration_returnsAllParams() {
        let request = BTPayPalCheckoutRequest(amount: "1")
        request.intent = .sale
        request.offerPayLater = true
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

        let parameters = request.parameters(with: configuration, isBillingAgreement: false)

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
    }

    func testParametersWithConfiguration_returnsMinimumParams() {
        let request = BTPayPalCheckoutRequest(amount: "1")

        let parameters = request.parameters(with: configuration, isBillingAgreement: false)

        XCTAssertEqual(parameters["intent"] as? String, "authorize")
        XCTAssertEqual(parameters["amount"] as? String, "1")
        XCTAssertEqual(parameters["offer_pay_later"] as? Bool, false)
    }

    func testParametersWithConfiguration_whenCurrencyCodeNotSet_usesConfigCurrencyCode() {
        let json = BTJSON(value: [
            "paypalEnabled": true,
            "paypal": [
                "currencyIsoCode": "currency-code"
            ]
        ])

        configuration = BTConfiguration(json: json)

        let request = BTPayPalCheckoutRequest(amount: "1")
        let parameters = request.parameters(with: configuration, isBillingAgreement: false)

        XCTAssertEqual(parameters["currency_iso_code"] as? String, "currency-code")
    }
}
