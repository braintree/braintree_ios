import XCTest
import PassKit

class BTConfiguration_Tests: XCTestCase {

    override func tearDown() {
        BTConfiguration.setBetaPaymentOption("venmo", isEnabled: false)
    }
    
    func testInitWithJSON_setsJSON() {
        let json = BTJSON(value: [
            "some": "things",
            "number": 1,
            "array": [1, 2, 3]])
        let configuration = BTConfiguration(JSON: json)

        XCTAssertEqual(configuration.json, json)
    }

    // MARK: - Beta enabled payment option
    
    func testIsBetaEnabledPaymentOption_returnsFalse() {
        XCTAssertFalse(BTConfiguration.isBetaEnabledPaymentOption("venmo"))
    }

    // MARK: - Venmo category methods

    func testIsVenmoEnabled_whenBetaVenmoIsEnabledAndAccessTokenIsPresent_returnsTrue() {
        let configurationJSON = BTJSON(value: [
            "payWithVenmo": [ "accessToken": "some access token" ]
            ])
        let configuration = BTConfiguration(JSON: configurationJSON)
        
        XCTAssertTrue(configuration.isVenmoEnabled)
    }

    func testIsVenmoEnabled_whenBetaVenmoIsEnabledAndAccessTokenNotPresent_returnsFalse() {
        let configurationJSON = BTJSON(value: [
            "payWithVenmo": []
            ])
        let configuration = BTConfiguration(JSON: configurationJSON)

        XCTAssertFalse(configuration.isVenmoEnabled)
    }

    func testVenmoAccessToken_returnsVenmoAccessToken() {
        let configurationJSON = BTJSON(value: [
            "payWithVenmo": [ "accessToken": "some access token" ]
            ])
        let configuration = BTConfiguration(JSON: configurationJSON)

        XCTAssertEqual(configuration.venmoAccessToken, "some access token")
    }

    func testEnableVenmo_whenDisabled_setsVenmoBetaPaymentOptionToFalse() {
        BTConfiguration.enableVenmo(false)
        XCTAssertFalse(BTConfiguration.isBetaEnabledPaymentOption("venmo"))
    }

    // MARK: - PayPal category methods

    func testIsPayPalEnabled_returnsPayPalEnabledStatusFromConfigurationJSON() {
        for isPayPalEnabled in [true, false] {
            let configurationJSON = BTJSON(value: [ "paypalEnabled": isPayPalEnabled ])
            let configuration = BTConfiguration(JSON: configurationJSON)

            XCTAssertTrue(configuration.isPayPalEnabled == isPayPalEnabled)
        }
    }

    func testIsPayPalEnabled_whenPayPalEnabledStatusNotPresentInConfigurationJSON_returnsFalse() {
        let configuration = BTConfiguration(JSON: BTJSON(value: []))
        XCTAssertFalse(configuration.isPayPalEnabled)
    }

    func testIsBillingAgreementsEnabled_returnsBillingAgreementsStatusFromConfigurationJSON() {
        for isBillingAgreementsEnabled in [true, false] {
            let configurationJSON = BTJSON(value: [
                "paypal": [ "billingAgreementsEnabled": isBillingAgreementsEnabled]
                ])
            let configuration = BTConfiguration(JSON: configurationJSON)
            XCTAssertTrue(configuration.isBillingAgreementsEnabled == isBillingAgreementsEnabled)
        }
    }

    // MARK: - Apple Pay category methods

    func testIsApplePayEnabled_whenApplePayStatusFromConfigurationJSONIsAString_returnsTrue() {
        for applePayStatus in ["mock", "production", "asdfasdf"] {
            let configurationJSON = BTJSON(value: [
                "applePay": [ "status": applePayStatus ]
                ])
            let configuration = BTConfiguration(JSON: configurationJSON)

            XCTAssertTrue(configuration.isApplePayEnabled)
        }
    }
    
    func testApplePaySupportedNetworks_returnsCorrectPKCardNetworkTypes() {
        let configurationJSON = BTJSON(value: [
            "applePay": [
                "status": "off",
                // From Gateway::ApplePayService#supportedNetworks:296-300
                "supportedNetworks": ["visa", "amex", "mastercard", "discover"]
            ]
        ])
        let configuration = BTConfiguration(JSON: configurationJSON)
        let supportedNetworks = configuration.applePaySupportedNetworks;
       
        XCTAssertEqual(supportedNetworks[0] as? String, PKPaymentNetworkVisa)
        XCTAssertEqual(supportedNetworks[1] as? String, PKPaymentNetworkAmex)
        XCTAssertEqual(supportedNetworks[2] as? String, PKPaymentNetworkMasterCard)
        if #available(iOS 9, *) {
            XCTAssertEqual(supportedNetworks[3] as? String, PKPaymentNetworkDiscover)
        }
    }

    func testIsApplePayEnabled_whenApplePayStatusFromConfigurationJSONIsGarbage_returnsFalse() {
        let configurationJSON = BTJSON(value: [
            "applePay": [ "status": 3.14 ]
            ])
        let configuration = BTConfiguration(JSON: configurationJSON)

        XCTAssertFalse(configuration.isApplePayEnabled)
    }

    func testIsApplePayEnabled_whenApplePayStatusFromConfigurationJSONIsOff_returnsFalse() {
        let configurationJSON = BTJSON(value: [
            "applePay": [ "status": "off" ]
            ])
        let configuration = BTConfiguration(JSON: configurationJSON)

        XCTAssertFalse(configuration.isApplePayEnabled)
    }

    // MARK: - UnionPay category methods

    func testIsUnionPayEnabled_whenUnionPayEnabledFromConfigurationJSONIsTrue_returnsTrue() {
        let configurationJSON = BTJSON(value: [
            "unionPay": [ "enabled": true ]
            ])
        let configuration = BTConfiguration(JSON: configurationJSON)

        XCTAssertTrue(configuration.isUnionPayEnabled)
    }

    func testIsUnionPayEnabled_whenUnionPayEnabledFromConfigurationJSONIsFalse_returnsFalse() {
        let configurationJSON = BTJSON(value: [
            "unionPay": [ "enabled": false ]
            ])
        let configuration = BTConfiguration(JSON: configurationJSON)

        XCTAssertFalse(configuration.isUnionPayEnabled)

    }

    func testIsUnionPayEnabled_whenUnionPayEnabledFromConfigurationJSONIsMissing_returnsFalse() {
        let configurationJSON = BTJSON(value: [])
        let configuration = BTConfiguration(JSON: configurationJSON)

        XCTAssertFalse(configuration.isUnionPayEnabled)
    }

}
