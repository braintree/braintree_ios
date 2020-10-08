import XCTest

class BTConfiguration_Venmo_Tests: XCTestCase {
    func testVenmoIsEnabled_whenAccessTokenIsPresent_returnsTrue() {
        let configurationJSON = BTJSON(value: [
            "payWithVenmo": [ "accessToken": "some access token" ]
        ])
        let configuration = BTConfiguration(json: configurationJSON)

        XCTAssertTrue(configuration.isVenmoEnabled)
    }

    func testIsVenmoEnabled_whenAccessTokenNotPresent_returnsFalse() {
        let configurationJSON = BTJSON(value: [
            "payWithVenmo": [:]
        ])
        let configuration = BTConfiguration(json: configurationJSON)

        XCTAssertFalse(configuration.isVenmoEnabled)
    }

    func testVenmoAccessToken_returnsVenmoAccessToken() {
        let configurationJSON = BTJSON(value: [
            "payWithVenmo": [ "accessToken": "some access token" ]
        ])
        let configuration = BTConfiguration(json: configurationJSON)

        XCTAssertEqual(configuration.venmoAccessToken, "some access token")
    }

    func testVenmoEnvironment_returnsVenmoEnvironment() {
        let configurationJSON = BTJSON(value: [
            "payWithVenmo": [ "environment": "rockbox" ]
        ])
        let configuration = BTConfiguration(json: configurationJSON)

        XCTAssertEqual(configuration.venmoEnvironment, "rockbox")
    }
}
