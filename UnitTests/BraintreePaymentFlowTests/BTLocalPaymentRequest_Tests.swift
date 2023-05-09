import XCTest
@testable import BraintreeTestShared

class BTLocalPaymentRequest_UnitTests: XCTestCase {

//    func testHandleRequest_sendsPOSTRequest() {
//        let mockClient = MockAPIClient(authorization: "development_tokenization_key")!
//        mockClient.cannedConfigurationResponseBody = BTJSON(value: [
//            "paypalEnabled": true
//        ])
//
//        let request = BTLocalPaymentRequest()
//        request.amount = "100.00"
//        request.paymentType = "payment-type"
//        request.paymentTypeCountryCode = "US"
//
//        let address = BTPostalAddress()
//        address.streetAddress = "street-address"
//        address.extendedAddress = "extended-address"
//        address.locality = "Chicago"
//        address.region = "IL"
//        address.postalCode = "12345"
//        address.countryCodeAlpha2 = "US"
//        request.address = address
//
//        request.currencyCode = "USD"
//        request.givenName = "Jane"
//        request.surname = "Doe"
//        request.email = "test@example.com"
//        request.phone = "1231231234"
//        request.merchantAccountID = "account-id"
//        request.bic = "bank-id-code"
//        request.isShippingAddressRequired = true
//        request.displayName = "My Brand!"
//
//        let mockRequestDelegate = MockLocalPaymentRequestDelegate()
//        request.localPaymentFlowDelegate = mockRequestDelegate
//        request.startPaymentFlow(request) { _, _ in }
//
//        XCTAssertEqual(mockClient.lastPOSTPath, "v1/local_payments/create")
//
//        guard let params = mockClient.lastPOSTParameters else { XCTFail(); return }
//
//        XCTAssertEqual(params["amount"] as! String, "100.00")
//        XCTAssertEqual(params["funding_source"] as! String, "payment-type")
//        XCTAssertEqual(params["intent"] as! String, "sale")
//        XCTAssertEqual(params["return_url"] as! String, "sdk.ios.braintree://x-callback-url/braintree/local-payment/success")
//        XCTAssertEqual(params["cancel_url"] as! String, "sdk.ios.braintree://x-callback-url/braintree/local-payment/cancel")
//        XCTAssertEqual(params["payment_type_country_code"] as! String, "US")
//        XCTAssertEqual(params["line1"] as! String, "street-address")
//        XCTAssertEqual(params["line2"] as! String, "extended-address")
//        XCTAssertEqual(params["city"] as! String, "Chicago")
//        XCTAssertEqual(params["state"] as! String, "IL")
//        XCTAssertEqual(params["postal_code"] as! String, "12345")
//        XCTAssertEqual(params["country_code"] as! String, "US")
//        XCTAssertEqual(params["first_name"] as! String, "Jane")
//        XCTAssertEqual(params["last_name"] as! String, "Doe")
//        XCTAssertEqual(params["payer_email"] as! String, "test@example.com")
//        XCTAssertEqual(params["phone"] as! String, "1231231234")
//        XCTAssertEqual(params["merchant_account_id"] as! String, "account-id")
//        XCTAssertEqual(params["bic"] as! String, "bank-id-code")
//
//        let experienceProfile = params["experience_profile"] as! [String: Any]
//        XCTAssertEqual(experienceProfile["brand_name"] as! String, "My Brand!")
//        XCTAssertEqual(experienceProfile["no_shipping"] as! Bool, false)
//    }
}
