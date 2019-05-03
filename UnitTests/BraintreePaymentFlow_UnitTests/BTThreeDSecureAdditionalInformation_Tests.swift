import XCTest

class BTThreeDSecureAdditionalInformation_Tests: XCTestCase {
    func testAsParameters_parameterizesAllProperties() {
        let info = BTThreeDSecureAdditionalInformation()

        let shippingAddress = BTThreeDSecurePostalAddress()
        shippingAddress.givenName = "Given"
        shippingAddress.surname = "Surname"
        shippingAddress.streetAddress = "123 Street Address"
        shippingAddress.extendedAddress = "Suite Number"
        shippingAddress.locality = "Locality"
        shippingAddress.region = "Region"
        shippingAddress.postalCode = "12345"
        shippingAddress.countryCodeAlpha2 = "US"
        shippingAddress.phoneNumber = "1234567"
        info.shippingAddress = shippingAddress

        info.shippingMethodIndicator = "01"
        // TODO: Add rest of properties to test

        let parameters = info.asParameters() as! Dictionary<String, String>

        XCTAssertEqual(parameters["shippingGivenName"], "Given")
        XCTAssertEqual(parameters["shippingSurname"], "Surname")
        XCTAssertEqual(parameters["shippingLine1"], "123 Street Address")
        XCTAssertEqual(parameters["shippingLine2"], "Suite Number")
        XCTAssertEqual(parameters["shippingCity"], "Locality")
        XCTAssertEqual(parameters["shippingState"], "Region")
        XCTAssertEqual(parameters["shippingPostalCode"], "12345")
        XCTAssertEqual(parameters["shippingCountryCode"], "US")
        XCTAssertEqual(parameters["shippingPhone"], "1234567")
        XCTAssertEqual(parameters["shippingMethodIndicator"], "01")
    }

    func testAsParameters_parameterizesWithNilProperties() {
        let info = BTThreeDSecureAdditionalInformation()
        info.productCode = "AIR"

        let parameters = info.asParameters() as! Dictionary<String, String>

        XCTAssertNil(parameters["shippingMethodIndicator"])
        XCTAssertEqual(parameters["productCode"], "AIR")
    }
}
