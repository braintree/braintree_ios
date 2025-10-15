import XCTest
import BraintreeCore

class BTPostalAddress_Tests: XCTestCase {

    func testInitializer_setsAllProperties() {
        let postalAddress = BTPostalAddress(
            recipientName: "Jane Smith",
            streetAddress: "555 Smith St.",
            extendedAddress: "#5",
            locality: "Oakland",
            countryCodeAlpha2: "US",
            postalCode: "54321",
            region: "CA"
        )
        
        let addressComponents = postalAddress.addressComponents()

        XCTAssertEqual(addressComponents["recipientName"], "Jane Smith")
        XCTAssertEqual(addressComponents["streetAddress"], "555 Smith St.")
        XCTAssertEqual(addressComponents["extendedAddress"], "#5")
        XCTAssertEqual(addressComponents["locality"], "Oakland")
        XCTAssertEqual(addressComponents["region"], "CA")
        XCTAssertEqual(addressComponents["countryCodeAlpha2"], "US")
        XCTAssertEqual(addressComponents["postalCode"], "54321")
    }
}
