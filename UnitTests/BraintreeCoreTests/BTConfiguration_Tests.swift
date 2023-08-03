import XCTest
import PassKit
import BraintreeVenmo

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

    func testVenmoEnrichedCustomerDataEnabled_returnsEcd() {
        var configurationJSON = BTJSON(value: [
            "payWithVenmo": ["enrichedCustomerDataEnabled": true]
        ])
        var configuration = BTConfiguration(json: configurationJSON)

        XCTAssertTrue(configuration.isVenmoEnrichedCustomerDataEnabled)

        configurationJSON = BTJSON(value: [
            "payWithVenmo": ["enrichedCustomerDataEnabled": false]
        ])
        configuration = BTConfiguration(json: configurationJSON)

        XCTAssertFalse(configuration.isVenmoEnrichedCustomerDataEnabled)

        configurationJSON = BTJSON(value: ["payWithVenmo": [:]])
        configuration = BTConfiguration(json: configurationJSON)

        XCTAssertFalse(configuration.isVenmoEnrichedCustomerDataEnabled)
    }
}
