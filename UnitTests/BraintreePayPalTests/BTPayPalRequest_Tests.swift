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

        request.lineItems = [BTPayPalLineItem(quantity: "1", unitAmount: "1", name: "item", kind: .credit)]

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
                                                                                   "kind": "credit"]])

        XCTAssertEqual(parameters["return_url"] as? String, "sdk.ios.braintree://onetouch/v1/success")
        XCTAssertEqual(parameters["cancel_url"] as? String, "sdk.ios.braintree://onetouch/v1/cancel")
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
}
