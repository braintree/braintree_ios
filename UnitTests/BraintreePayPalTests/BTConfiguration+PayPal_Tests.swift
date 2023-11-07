import XCTest
import BraintreeTestShared
@testable import BraintreeCore
@testable import BraintreePayPal

class BTConfiguration_PayPal_Tests : XCTestCase {
    func testIsPayPalEnable_whenEnabled_returnsTrue() {
        let configurationJSON = BTJSON(value: [
            "paypalEnabled": true
        ])
        let configuration = BTConfiguration(json: configurationJSON)

        XCTAssertTrue(configuration.isPayPalEnabled)
    }

    func testIsPayPalEnabled_whenDisabled_returnsFalse() {
        let configurationJSON = BTJSON(value: [
            "paypalEnabled": false
        ])
        let configuration = BTConfiguration(json: configurationJSON)

        XCTAssertFalse(configuration.isPayPalEnabled)
    }

    func testIsPayPalEnabled_whenPayPalEnabledStatusNotPresentInConfigurationJSON_returnsFalse() {
        let configuration = BTConfiguration(json: BTJSON(value: [] as [Any?]))
        XCTAssertFalse(configuration.isPayPalEnabled)
    }

    func testIsBillingAgreementsEnabled_returnsBillingAgreementsStatusFromConfigurationJSON() {
        for isBillingAgreementsEnabled in [true, false] {
            let configurationJSON = BTJSON(value: [
                "paypal": [ "billingAgreementsEnabled": isBillingAgreementsEnabled]
                ])
            let configuration = BTConfiguration(json: configurationJSON)
            XCTAssertTrue(configuration.isBillingAgreementsEnabled == isBillingAgreementsEnabled)
        }
    }
}
