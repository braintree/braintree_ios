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

    func testEnvironment_returnsEnvironment() {
        let configurationJSON = BTJSON(value: [
            "environment": "sandbox"
        ])
        let configuration = BTConfiguration(json: configurationJSON)
        XCTAssertEqual(configuration.environment, "sandbox")
    }
}
