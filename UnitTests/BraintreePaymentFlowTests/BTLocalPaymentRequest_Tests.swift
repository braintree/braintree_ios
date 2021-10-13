import XCTest
import BraintreeTestShared

class BTLocalPaymentRequest_UnitTests: XCTestCase {

    func testHandleRequest_sendsPOSTRequest() {
        let mockClient = MockAPIClient(authorization: "development_tokenization_key")!
        mockClient.cannedConfigurationResponseBody = BTJSON(value: [
            "paypalEnabled": true
        ])

        let request = BTLocalPaymentRequest()
        request.amount = "100.00"
        request.paymentType = "payment-type"
        request.paymentTypeCountryCode = "US"

        let address = BTPostalAddress()
        address.streetAddress = "street-address"
        address.extendedAddress = "extended-address"
        address.locality = "Chicago"
        address.region = "IL"
        address.postalCode = "12345"
        address.countryCodeAlpha2 = "US"
        request.address = address

        request.currencyCode = "USD"
        request.givenName = "Jane"
        request.surname = "Doe"
        request.email = "test@example.com"
        request.phone = "1231231234"
        request.merchantAccountID = "account-id"
        request.bic = "bank-id-code"
        request.isShippingAddressRequired = true
        request.displayName = "My Brand!"

        let mockRequestDelegate = MockLocalPaymentRequestDelegate()
        request.localPaymentFlowDelegate = mockRequestDelegate

        let mockDriverDelegate = MockPaymentFlowDriverDelegate()
        mockDriverDelegate._returnURLScheme = "com.app.payments"

        request.handle(request, client: mockClient, paymentDriverDelegate: mockDriverDelegate)

        XCTAssertEqual(mockClient.lastPOSTPath, "v1/local_payments/create")

        guard let params = mockClient.lastPOSTParameters else { XCTFail(); return }

        let expectedParams: [String : Any] = [
            "amount": "100.00",
            "funding_source": "payment-type",
            "intent": "sale",
            "return_url": "com.app.payments://x-callback-url/braintree/local-payment/success",
            "cancel_url": "com.app.payments://x-callback-url/braintree/local-payment/cancel",
            "payment_type_country_code": "US",
            "line1": "street-address",
            "line2": "extended-address",
            "city": "Chicago",
            "state": "IL",
            "postal_code": "12345",
            "country_code": "US",
            "currency_iso_code": "USD",
            "first_name": "Jane",
            "last_name": "Doe",
            "payer_email": "test@example.com",
            "phone": "1231231234",
            "merchant_account_id": "account-id",
            "bic": "bank-id-code",
            "experience_profile": [
                "brand_name": "My Brand!",
                "no_shipping": false
            ]
        ]

        XCTAssertEqual(params as NSObject, expectedParams as NSObject)
    }
}
