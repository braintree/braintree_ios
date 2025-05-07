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

        let parameters = request.parameters(with: configuration)

        XCTAssertEqual(parameters["description"] as? String, "desc")
        XCTAssertEqual(parameters["offer_paypal_credit"] as? Bool, true)
        XCTAssertEqual(parameters["payer_email"] as? String, "fake@email.com")
        XCTAssertNil(parameters["launch_paypal_app"])
        XCTAssertNil(parameters["os_version"])
        XCTAssertNil(parameters["os_type"])
        XCTAssertNil(parameters["merchant_app_return_url"])
        
        guard let userPhoneNumberDetails = parameters["phone_number"] as? [String: String] else {
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
            userAuthenticationEmail: "sally@gmail.com",
            enablePayPalAppSwitch: true
        )

        let parameters = request.parameters(with: configuration, universalLink: URL(string: "some-url")!, isPayPalAppInstalled: true)

        XCTAssertEqual(parameters["launch_paypal_app"] as? Bool, true)
        XCTAssertTrue((parameters["os_version"] as! String).matches("\\d+\\.\\d+"))
        XCTAssertTrue((parameters["os_type"] as! String).matches("iOS|iPadOS"))
        XCTAssertEqual(parameters["merchant_app_return_url"] as? String, "some-url")
    }
    
    func testParametersWithConfiguration_setsAppSwitchParameters_withoutUserAuthenticationEmail() {
        let request = BTPayPalVaultRequest(
            enablePayPalAppSwitch: true
        )
        
        let parameters = request.parameters(with: configuration, universalLink: URL(string: "some-merchant-url")!, isPayPalAppInstalled: true)
        
        XCTAssertNil(parameters["payer_email"])
        XCTAssertEqual(parameters["launch_paypal_app"] as? Bool, true)
        XCTAssertTrue((parameters["os_version"] as! String).matches("\\d+\\.\\d+"))
        XCTAssertTrue((parameters["os_type"] as! String).matches("iOS|iPadOS"))
        XCTAssertEqual(parameters["merchant_app_return_url"] as? String, "some-merchant-url")
    }
}
