import XCTest
import BraintreeCore

class BTPostalAddress_Tests: XCTestCase {

    func testAsParameters_setsAllProperties() {
        let postalAddress = BTPostalAddress()
        postalAddress.recipientName = "Jane Smith"
        postalAddress.streetAddress = "555 Smith St."
        postalAddress.extendedAddress = "#5"
        postalAddress.locality = "Oakland"
        postalAddress.region = "CA"
        postalAddress.countryCodeAlpha2 = "US"
        postalAddress.postalCode = "54321"

        XCTAssertEqual(postalAddress.recipientName, "Jane Smith")
        XCTAssertEqual(postalAddress.streetAddress, "555 Smith St.")
        XCTAssertEqual(postalAddress.extendedAddress, "#5")
        XCTAssertEqual(postalAddress.locality, "Oakland")
        XCTAssertEqual(postalAddress.region, "CA")
        XCTAssertEqual(postalAddress.countryCodeAlpha2, "US")
        XCTAssertEqual(postalAddress.postalCode, "54321")
    }
}
