import XCTest

class BTThreeDSecureAdditionalInformation_Tests: XCTestCase {
    func testAsParameters_parameterizesAllProperties() {
        let info = BTThreeDSecureAdditionalInformation()
        info.billingGivenName = "Jill"
        info.billingSurname = "Smith"
        info.billingPhoneNumber = "1231234567"
        info.email = "email@email.com"
        info.shippingMethod = "02"

        let billingAddress = BTThreeDSecurePostalAddress()
        billingAddress.streetAddress = "123 Fake St"
        billingAddress.extendedAddress = "Unit 2"
        billingAddress.locality = "Chicago"
        billingAddress.region = "IL"
        billingAddress.countryCodeAlpha2 = "US"
        billingAddress.postalCode = "12345"
        info.billingAddress = billingAddress

        let parameters = info.asParameters() as! Dictionary<String, String>

        XCTAssertEqual(parameters["email"], "email@email.com")
        XCTAssertEqual(parameters["shippingMethod"], "02")
        XCTAssertEqual(parameters["billingGivenName"], "Jill")
        XCTAssertEqual(parameters["billingSurname"], "Smith")
        XCTAssertEqual(parameters["billingPhoneNumber"], "1231234567")
        XCTAssertEqual(parameters["billingLine1"], "123 Fake St")
        XCTAssertEqual(parameters["billingLine2"], "Unit 2")
        XCTAssertEqual(parameters["billingPostalCode"], "12345")
    }

    func testAsParameters_parameterizesWithNilProperties() {
        let info = BTThreeDSecureAdditionalInformation()
        info.billingGivenName = "Jill"
        info.billingSurname = "Smith"
        info.email = "email@email.com"

        let billingAddress = BTThreeDSecurePostalAddress()
        billingAddress.streetAddress = "123 Fake St"
        billingAddress.extendedAddress = "Unit 2"
        info.billingAddress = billingAddress

        let parameters = info.asParameters() as! Dictionary<String, String>

        XCTAssertEqual(parameters["email"], "email@email.com")
        XCTAssertNil(parameters["shippingMethod"])
        XCTAssertEqual(parameters["billingGivenName"], "Jill")
        XCTAssertEqual(parameters["billingSurname"], "Smith")
        XCTAssertNil(parameters["billingPhoneNumber"])
        XCTAssertEqual(parameters["billingLine1"], "123 Fake St")
        XCTAssertEqual(parameters["billingLine2"], "Unit 2")
        XCTAssertNil(parameters["billingPostalCode"])
    }

    func testAsParameters_parameterizesWithNilBillingAddress() {
        let info = BTThreeDSecureAdditionalInformation()
        info.billingGivenName = "Jill"

        let parameters = info.asParameters() as! Dictionary<String, String>
        XCTAssertEqual(parameters["billingGivenName"], "Jill")
        XCTAssertNil(parameters["billingAddress"])
    }
}
