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

        let parameters = address.asParameters() as! Dictionary<String, String>
        XCTAssertEqual(parameters["billingGivenName"], "Joe")
        XCTAssertEqual(parameters["billingSurname"], "Guy")
        XCTAssertEqual(parameters["billingPhoneNumber"], "12345678")
        XCTAssertEqual(parameters["billingLine1"], "555 Smith St.")
        XCTAssertEqual(parameters["billingLine2"], "#5")
        XCTAssertEqual(parameters["billingCity"], "Oakland")
        XCTAssertEqual(parameters["billingState"], "CA")
        XCTAssertEqual(parameters["billingCountryCode"], "US")
        XCTAssertEqual(parameters["billingPostalCode"], "54321")
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

        let parameters = address.asParameters()  as! Dictionary<String, String>
        XCTAssertEqual(parameters["billingGivenName"], "Joe")
        XCTAssertEqual(parameters["billingSurname"], "Guy")
        XCTAssertEqual(parameters["billingLine1"], "555 Smith St.")
        XCTAssertNil(parameters["billingLine2"])
        XCTAssertEqual(parameters["billingCity"], "Oakland")
        XCTAssertEqual(parameters["billingState"], "CA")
        XCTAssertEqual(parameters["billingCountryCode"], "US")
        XCTAssertEqual(parameters["billingPostalCode"], "54321")
    }

    func testAsParameters_parameterizesWithOnlyNilProperties() {
        let address = BTThreeDSecurePostalAddress()

        let parameters = address.asParameters()
        XCTAssertNil(parameters["billingFirstName"])
        XCTAssertNil(parameters["billingLastName"])
        XCTAssertNil(parameters["billingPhoneNumber"])
    }
}
