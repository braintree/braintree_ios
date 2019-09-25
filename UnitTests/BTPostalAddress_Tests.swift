import XCTest

class BTPostalAddress_Tests: XCTestCase {

    func testCopiesAllProperties() {
        let originalAddress = BTPostalAddress()
        originalAddress.recipientName = "Jane Smith"
        originalAddress.streetAddress = "555 Smith St."
        originalAddress.extendedAddress = "#5"
        originalAddress.locality = "Oakland"
        originalAddress.region = "CA"
        originalAddress.countryCodeAlpha2 = "US"
        originalAddress.postalCode = "54321"

        let addressCopy = originalAddress.copy() as! BTPostalAddress
        XCTAssertEqual(addressCopy.recipientName, "Jane Smith")
        XCTAssertEqual(addressCopy.streetAddress, "555 Smith St.")
        XCTAssertEqual(addressCopy.extendedAddress, "#5")
        XCTAssertEqual(addressCopy.locality, "Oakland")
        XCTAssertEqual(addressCopy.region, "CA")
        XCTAssertEqual(addressCopy.countryCodeAlpha2, "US")
        XCTAssertEqual(addressCopy.postalCode, "54321")
    }

    func testAsParameters_copiesWithOnlyNilProperties() {
        let originalAddress = BTPostalAddress()

        let addressCopy = originalAddress.copy() as! BTPostalAddress
        XCTAssertNil(addressCopy.recipientName)
        XCTAssertNil(addressCopy.streetAddress)
        XCTAssertNil(addressCopy.extendedAddress)
        XCTAssertNil(addressCopy.locality)
        XCTAssertNil(addressCopy.region)
        XCTAssertNil(addressCopy.countryCodeAlpha2)
        XCTAssertNil(addressCopy.postalCode)
    }
}
