import XCTest
import BraintreePayPal

class BTPayPalVaultRequest_Tests: XCTestCase {

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

        let parameters = request.parameters(with: configuration)

        XCTAssertEqual(parameters["description"] as? String, "desc")
        XCTAssertEqual(parameters["offer_paypal_credit"] as? Bool, true)

        guard let shippingParams = parameters["shipping_address"] as? [String:String] else { XCTFail(); return }

        XCTAssertEqual(shippingParams["line1"], "123 Main")
        XCTAssertEqual(shippingParams["line2"], "Unit 1")
        XCTAssertEqual(shippingParams["city"], "Chicago")
        XCTAssertEqual(shippingParams["state"], "IL")
        XCTAssertEqual(shippingParams["postal_code"], "11111")
        XCTAssertEqual(shippingParams["country_code"], "US")
        XCTAssertEqual(shippingParams["recipient_name"], "Recipient")
    }
}
