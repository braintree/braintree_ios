import XCTest
@testable import BraintreeCore
@testable import BraintreeThreeDSecure

class BTConfiguration_ThreeDSecure_Tests: XCTestCase {

    func testIsCardinalAuthenticationJWTReturned_whenCardinalAuthenticationJWTIsPresent() {
        let configurationJSON = BTJSON(value: [
            "threeDSecure": [ "cardinalAuthenticationJWT" : "123"]
            ])
        let configuration = BTConfiguration(json: configurationJSON)

        XCTAssertEqual(configuration.cardinalAuthenticationJWT, "123")
    }

}
