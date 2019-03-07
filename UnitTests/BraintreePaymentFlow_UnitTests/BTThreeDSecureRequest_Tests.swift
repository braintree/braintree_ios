import XCTest

class BTThreeDSecureRequest_Tests: XCTestCase {
    func testAsParameters_parameterizesAllProperties() {
        let request = BTThreeDSecureRequest()
        request.amount = 1.23
        request.mobilePhoneNumber = "13125551234"
        request.email = "email@email.com"
        request.shippingMethod = "01"

        let billingAddress = BTThreeDSecurePostalAddress()
        billingAddress.firstName = "First"
        billingAddress.lastName = "Last"
        billingAddress.phoneNumber = "1234567"
        billingAddress.streetAddress = "123 Fake St"
        request.billingAddress = billingAddress

        let parameters = request.asParameters()
        XCTAssertEqual(parameters["amount"] as! String, "1.23")

        let additionalInformation = parameters["additionalInformation"] as! Dictionary<String, String>
        XCTAssertEqual(additionalInformation["mobilePhoneNumber"], "13125551234")
        XCTAssertEqual(additionalInformation["email"], "email@email.com")
        XCTAssertEqual(additionalInformation["shippingMethod"], "01")
        XCTAssertEqual(additionalInformation["billingGivenName"], "First")
        XCTAssertEqual(additionalInformation["billingSurname"], "Last")
        XCTAssertEqual(additionalInformation["billingPhoneNumber"], "1234567")
        XCTAssertEqual(additionalInformation["billingLine1"], "123 Fake St")
    }

    func testAsParameters_parameterizesWithNilProperties() {
        let request = BTThreeDSecureRequest()
        request.amount = 1.23
        request.mobilePhoneNumber = "13125551234"

        let parameters = request.asParameters()
        XCTAssertEqual(parameters["amount"] as! String, "1.23")

        let additionalInformation = parameters["additionalInformation"] as! Dictionary<String, String>
        XCTAssertEqual(additionalInformation["mobilePhoneNumber"], "13125551234")
        XCTAssertNil(additionalInformation["email"])
        XCTAssertNil(additionalInformation["shippingMethod"])
        XCTAssertNil(additionalInformation["billingGivenName"])
        XCTAssertNil(additionalInformation["billingLine"])
    }

    func testAsParameters_parameterizesWithNilAdditionalInformation() {
        let request = BTThreeDSecureRequest()
        request.amount = 1.23

        let parameters = request.asParameters()
        XCTAssertEqual(parameters["amount"] as! String, "1.23")
        XCTAssertNil(parameters["additionalInformation"])
    }
}
