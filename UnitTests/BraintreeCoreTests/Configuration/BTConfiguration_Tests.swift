import XCTest
import PassKit

@testable import BraintreeCore

class BTConfiguration_Tests: XCTestCase {
    func testInitWithJSON_setsJSON() {
        let json = BTJSON(value: [
            "some": "things",
            "number": 1,
            "array": [1, 2, 3]] as [String: Any])
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
            ] as [String: Any?]
        ] as [String: Any])
        let configuration = BTConfiguration(json: configurationJSON)
        XCTAssertFalse(configuration.isGraphQLEnabled)
    }

    func testEnvironment_returnsEnvironment() {
        let configurationJSON = BTJSON(value: [
            "environment": "fake-env"
        ])
        let configuration = BTConfiguration(json: configurationJSON)
        XCTAssertEqual(configuration.environment, "fake-env")
    }
    
    func testFPTIEnvironment_whenProduction_returnsLive() {
        let configurationJSON = BTJSON(value: [
            "environment": "production"
        ])
        let configuration = BTConfiguration(json: configurationJSON)
        XCTAssertEqual(configuration.fptiEnvironment, "live")
    }
}
