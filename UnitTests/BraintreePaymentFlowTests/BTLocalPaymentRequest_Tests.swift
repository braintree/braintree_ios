import XCTest
@testable import BraintreePaymentFlow
@testable import BraintreeTestShared

class BTLocalPaymentRequest_UnitTests: XCTestCase {

    func testLocalPaymentRequest_returnsAllParameters() {
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

        XCTAssertEqual(request.amount, "100.00")
        XCTAssertEqual(request.paymentType, "payment-type")
        XCTAssertEqual(request.paymentTypeCountryCode, "US")
        XCTAssertEqual(request.address?.streetAddress, "street-address")
        XCTAssertEqual(request.address?.extendedAddress, "extended-address")
        XCTAssertEqual(request.address?.locality, "Chicago")
        XCTAssertEqual(request.address?.region, "IL")
        XCTAssertEqual(request.address?.postalCode, "12345")
        XCTAssertEqual(request.address?.countryCodeAlpha2, "US")
        XCTAssertEqual(request.givenName, "Jane")
        XCTAssertEqual(request.surname, "Doe")
        XCTAssertEqual(request.email, "test@example.com")
        XCTAssertEqual(request.phone, "1231231234")
        XCTAssertEqual(request.merchantAccountID, "account-id")
        XCTAssertEqual(request.bic, "bank-id-code")
    }
}
