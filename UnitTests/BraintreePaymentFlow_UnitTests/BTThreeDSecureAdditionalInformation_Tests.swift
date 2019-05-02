import XCTest

class BTThreeDSecureAdditionalInformation_Tests: XCTestCase {
    func testAsParameters_parameterizesAllProperties() {
        let info = BTThreeDSecureAdditionalInformation()
        info.shippingMethodIndicator = "01"
        // TODO: Add rest of properties to test

        let parameters = info.asParameters() as! Dictionary<String, String>

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
