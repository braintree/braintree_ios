import XCTest
import BraintreeTestShared
import BraintreeCore

class BTConfiguration_UnionPay_Tests : XCTestCase {
    func testIsUnionPayEnabled_whenUnionPayEnabledFromConfigurationJSONIsTrue_returnsTrue() {
        let configurationJSON = BTJSON(value: [
            "unionPay": [ "enabled": true ]
        ])
        let configuration = BTConfiguration(json: configurationJSON)

        XCTAssertTrue(configuration.isUnionPayEnabled)
    }

    func testIsUnionPayEnabled_whenUnionPayEnabledFromConfigurationJSONIsFalse_returnsFalse() {
        let configurationJSON = BTJSON(value: [
            "unionPay": [ "enabled": false ]
        ])
        let configuration = BTConfiguration(json: configurationJSON)

        XCTAssertFalse(configuration.isUnionPayEnabled)

    }

    func testIsUnionPayEnabled_whenUnionPayEnabledFromConfigurationJSONIsMissing_returnsFalse() {
        let configurationJSON = BTJSON(value: [])
        let configuration = BTConfiguration(json: configurationJSON)

        XCTAssertFalse(configuration.isUnionPayEnabled)
    }
}
