import XCTest
@testable import BraintreeThreeDSecure

class BTThreeDSecurePostalAddress_Tests: XCTestCase {

    func testAsParameters_parameterizesAllProperties() {
        let address = BTThreeDSecurePostalAddress()
        address.givenName = "Joe"
        address.surname = "Guy"
        address.phoneNumber = "12345678"
        address.streetAddress = "555 Smith St."
        address.extendedAddress = "#5"
        address.locality = "Oakland"
        address.region = "CA"
        address.countryCodeAlpha2 = "US"
        address.postalCode = "54321"

        let parameters = address.asParameters()
        XCTAssertEqual(parameters["givenName"], "Joe")
        XCTAssertEqual(parameters["surname"], "Guy")
        XCTAssertEqual(parameters["phoneNumber"], "12345678")
        XCTAssertEqual(parameters["line1"], "555 Smith St.")
        XCTAssertEqual(parameters["line2"], "#5")
        XCTAssertEqual(parameters["city"], "Oakland")
        XCTAssertEqual(parameters["state"], "CA")
        XCTAssertEqual(parameters["countryCode"], "US")
        XCTAssertEqual(parameters["postalCode"], "54321")
    }

    func testAsParameters_parameterizesWithNilProperties() {
        let address = BTThreeDSecurePostalAddress()
        address.givenName = "Joe"
        address.surname = "Guy"
        address.streetAddress = "555 Smith St."
        address.locality = "Oakland"
        address.region = "CA"
        address.countryCodeAlpha2 = "US"
        address.postalCode = "54321"

        let parameters = address.asParameters()
        XCTAssertEqual(parameters["givenName"], "Joe")
        XCTAssertEqual(parameters["surname"], "Guy")
        XCTAssertEqual(parameters["line1"], "555 Smith St.")
        XCTAssertNil(parameters["line2"])
        XCTAssertEqual(parameters["city"], "Oakland")
        XCTAssertEqual(parameters["state"], "CA")
        XCTAssertEqual(parameters["countryCode"], "US")
        XCTAssertEqual(parameters["postalCode"], "54321")
    }

    func testAsParameters_parameterizesWithOnlyNilProperties() {
        let address = BTThreeDSecurePostalAddress()

        let parameters = address.asParameters()
        XCTAssertNil(parameters["givenName"])
        XCTAssertNil(parameters["surname"])
        XCTAssertNil(parameters["phoneNumber"])
    }

    func testAsParametersWithPrefix_parameterizesAllProperties() {
        let address = BTThreeDSecurePostalAddress()
        address.givenName = "Joe"
        address.surname = "Guy"
        address.phoneNumber = "12345678"
        address.streetAddress = "555 Smith St."
        address.extendedAddress = "#5"
        address.line3 = "Suite C"
        address.locality = "Oakland"
        address.region = "CA"
        address.countryCodeAlpha2 = "US"
        address.postalCode = "54321"

        let parameters = address.asParameters(withPrefix: "billing")
        XCTAssertEqual(parameters["billingGivenName"], "Joe")
        XCTAssertEqual(parameters["billingSurname"], "Guy")
        XCTAssertEqual(parameters["billingPhoneNumber"], "12345678")
        XCTAssertEqual(parameters["billingLine1"], "555 Smith St.")
        XCTAssertEqual(parameters["billingLine2"], "#5")
        XCTAssertEqual(parameters["billingLine3"], "Suite C")
        XCTAssertEqual(parameters["billingCity"], "Oakland")
        XCTAssertEqual(parameters["billingState"], "CA")
        XCTAssertEqual(parameters["billingCountryCode"], "US")
        XCTAssertEqual(parameters["billingPostalCode"], "54321")
    }
}
