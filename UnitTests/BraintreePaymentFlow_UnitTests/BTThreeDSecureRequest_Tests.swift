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

        let additionalInformation = parameters["additionalInformation"] as! Dictionary<String, Any>
        XCTAssertEqual(additionalInformation["mobilePhoneNumber"] as! String, "13125551234")
        XCTAssertEqual(additionalInformation["email"] as! String, "email@email.com")
        XCTAssertEqual(additionalInformation["shippingMethod"] as! String, "01")
        XCTAssertEqual(additionalInformation["firstName"] as! String, "First")
        XCTAssertEqual(additionalInformation["lastName"] as! String, "Last")
        XCTAssertEqual(additionalInformation["phoneNumber"] as! String, "1234567")

        let billingAdddress = additionalInformation["billingAddress"] as! Dictionary<String, String>
        XCTAssertEqual(billingAdddress["line1"], "123 Fake St")
    }

    func testAsParameters_parameterizesWithNilProperties() {
        let request = BTThreeDSecureRequest()
        request.amount = 1.23
        request.mobilePhoneNumber = "13125551234"

        let parameters = request.asParameters()
        XCTAssertEqual(parameters["amount"] as! String, "1.23")

        let additionalInformation = parameters["additionalInformation"] as! Dictionary<String, Any>
        XCTAssertEqual(additionalInformation["mobilePhoneNumber"] as! String, "13125551234")
        XCTAssertNil(additionalInformation["email"])
        XCTAssertNil(additionalInformation["shippingMethod"])
        XCTAssertNil(additionalInformation["firstName"])
        XCTAssertNil(additionalInformation["billingAddress"])
    }

    func testAsParameters_parameterizesWithNilAdditionalInformation() {
        let request = BTThreeDSecureRequest()
        request.amount = 1.23

        let parameters = request.asParameters()
        XCTAssertEqual(parameters["amount"] as! String, "1.23")
        XCTAssertNil(parameters["additionalInformation"])
    }
}
