import XCTest
import PassKit

class BTConfiguration_Tests: XCTestCase {
    func testInitWithJSON_setsJSON() {
        let json = BTJSON(value: [
            "some": "things",
            "number": 1,
            "array": [1, 2, 3]])
        let configuration = BTConfiguration(json: json)

        XCTAssertEqual(configuration.json, json)
    }

    //TODO: Move this to PaymentFlow tests
    // MARK: - PaymentFlow ThreeDSecure category methods

//    func testIsCardinalAuthenticationJWTReturned_whenCardinalAuthenticationJWTIsPresent() {
//        let configurationJSON = BTJSON(value: [
//            "threeDSecure": [ "cardinalAuthenticationJWT" : "123"]
//            ])
//        let configuration = BTConfiguration(json: configurationJSON)
//
//        XCTAssertEqual(configuration.cardinalAuthenticationJWT, "123")
//    }

    func testIsGraphQLEnabled_whenGraphQLURLExistsAndIsntEmpty_returnsTrue() {
        let configurationJSON = BTJSON(value: [
            "graphQL": [
                "url": "https://graphql.com"
            ]
        ])
        let configuration = BTConfiguration(json: configurationJSON)
        XCTAssertTrue(configuration.isGraphQLEnabled)
    }
    
    func testIsGraphQLEnabled_whenGraphQLURLIsMissing_returnsFalse() {
        let configurationJSON = BTJSON(value: [
            "graphQL": [
                "url": nil
            ]
        ])
        let configuration = BTConfiguration(json: configurationJSON)
        XCTAssertFalse(configuration.isGraphQLEnabled)
    }
}
