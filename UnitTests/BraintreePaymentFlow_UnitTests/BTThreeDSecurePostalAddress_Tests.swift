import XCTest

class BTThreeDSecurePostalAddress_Tests: XCTestCase {
    
    func testCopiesAllProperties() {
        let originalAddress = BTThreeDSecurePostalAddress()
        originalAddress.firstName = "Joe"
        originalAddress.lastName = "Guy"
        originalAddress.phoneNumber = "12345678"
        originalAddress.streetAddress = "555 Smith St."
        originalAddress.extendedAddress = "#5"
        originalAddress.locality = "Oakland"
        originalAddress.region = "CA"
        originalAddress.countryCodeAlpha2 = "US"
        originalAddress.postalCode = "54321"
        
        let addressCopy = originalAddress.copy() as! BTThreeDSecurePostalAddress
        XCTAssertEqual(addressCopy.firstName, "Joe")
        XCTAssertEqual(addressCopy.lastName, "Guy")
        XCTAssertEqual(addressCopy.phoneNumber, "12345678")
        XCTAssertEqual(addressCopy.streetAddress, "555 Smith St.")
        XCTAssertEqual(addressCopy.extendedAddress, "#5")
        XCTAssertEqual(addressCopy.locality, "Oakland")
        XCTAssertEqual(addressCopy.region, "CA")
        XCTAssertEqual(addressCopy.countryCodeAlpha2, "US")
        XCTAssertEqual(addressCopy.postalCode, "54321")
    }

    func testAsParameters_parameterizesAllProperties() {
        let address = BTThreeDSecurePostalAddress()
        address.firstName = "Joe"
        address.lastName = "Guy"
        address.phoneNumber = "12345678"
        address.streetAddress = "555 Smith St."
        address.extendedAddress = "#5"
        address.locality = "Oakland"
        address.region = "CA"
        address.countryCodeAlpha2 = "US"
        address.postalCode = "54321"

        let parameters = address.asParameters()
        XCTAssertEqual(parameters["firstName"] as! String, "Joe")
        XCTAssertEqual(parameters["lastName"] as! String, "Guy")
        XCTAssertEqual(parameters["phoneNumber"] as! String, "12345678")
        let billingAdddress = parameters["billingAddress"] as! Dictionary<String, String>
        XCTAssertEqual(billingAdddress["line1"], "555 Smith St.")
        XCTAssertEqual(billingAdddress["line2"], "#5")
        XCTAssertEqual(billingAdddress["city"], "Oakland")
        XCTAssertEqual(billingAdddress["state"], "CA")
        XCTAssertEqual(billingAdddress["countryCode"], "US")
        XCTAssertEqual(billingAdddress["postalCode"], "54321")
    }

    func testAsParameters_parameterizesWithNilProperties() {
        let address = BTThreeDSecurePostalAddress()
        address.firstName = "Joe"
        address.lastName = "Guy"
        address.streetAddress = "555 Smith St."
        address.locality = "Oakland"
        address.region = "CA"
        address.countryCodeAlpha2 = "US"
        address.postalCode = "54321"

        let parameters = address.asParameters()
        XCTAssertEqual(parameters["firstName"] as! String, "Joe")
        XCTAssertEqual(parameters["lastName"] as! String, "Guy")
        XCTAssertNil(parameters["phoneNumber"])
        let billingAdddress = parameters["billingAddress"] as! Dictionary<String, String>
        XCTAssertEqual(billingAdddress["line1"], "555 Smith St.")
        XCTAssertNil(billingAdddress["line2"])
        XCTAssertEqual(billingAdddress["city"], "Oakland")
        XCTAssertEqual(billingAdddress["state"], "CA")
        XCTAssertEqual(billingAdddress["countryCode"], "US")
        XCTAssertEqual(billingAdddress["postalCode"], "54321")
    }

    func testAsParameters_parameterizesWithOnlyNilProperties() {
        let address = BTThreeDSecurePostalAddress()

        let parameters = address.asParameters()
        XCTAssertNil(parameters["firstName"])
        XCTAssertNil(parameters["lastName"])
        XCTAssertNil(parameters["phoneNumber"])
        XCTAssertNil(parameters["billingAddress"])
    }
}
