import XCTest
@testable import BraintreePayPalNativeCheckout
@testable import BraintreeCore

class BTPayPalNativeVaultRequest_Tests: XCTestCase {
    
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
        let checkoutRequest = BTPayPalNativeVaultRequest()
        XCTAssertTrue(checkoutRequest.paymentType == .vault, "Incorrect payment type on CheckoutRequest")
    }
    
    func testHermesPathIsCorrect() {
        let checkoutRequest = BTPayPalNativeVaultRequest()
        XCTAssertEqual(checkoutRequest.hermesPath,"v1/paypal_hermes/setup_billing_agreement")
    }
    
    func testParametersWithConfiguration_returnsAllParams() {
        let request = BTPayPalNativeVaultRequest()
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
        request.riskCorrelationID = "risk ID"
        request.merchantAccountID = "merchant ID"
        
        let parameters = request.parameters(with: configuration)
        
        XCTAssertEqual(parameters["description"] as? String, "desc")
        XCTAssertEqual(parameters["offer_paypal_credit"] as? Bool, true)
        XCTAssertEqual(parameters["correlation_id"] as? String, "risk ID")
        XCTAssertEqual(parameters["merchant_account_id"] as? String, "merchant ID")

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
