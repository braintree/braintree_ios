import XCTest
import BraintreeTestShared

class BTConfiguration_ApplePay_Tests : XCTestCase {
    var mockAPIClient = MockAPIClient.init(authorization: "development_tokenization_key", sendAnalyticsEvent: false)!

    func testIsApplePayEnabled_whenApplePayStatusFromConfigurationJSONIsAString_returnsTrue() {
        for applePayStatus in ["mock", "production", "asdfasdf"] {
            let configurationJSON = BTJSON(value: [
                "applePay": [ "status": applePayStatus ]
            ])
            let configuration = BTConfiguration(json: configurationJSON)

            XCTAssertTrue(configuration.isApplePayEnabled)
        }
    }

    func testIsApplePayEnabled_whenApplePayStatusFromConfigurationJSONIsOff_returnsFalse() {
        let configurationJSON = BTJSON(value: [
            "applePay": [ "status": "off" ]
        ])
        let configuration = BTConfiguration(json: configurationJSON)

        XCTAssertFalse(configuration.isApplePayEnabled)
    }

    func testIsApplePayEnabled_whenApplePayStatusFromConfigurationJSONIsGarbage_returnsFalse() {
        let configurationJSON = BTJSON(value: [
            "applePay": [ "status": 3.14 ]
        ])
        let configuration = BTConfiguration(json: configurationJSON)

        XCTAssertFalse(configuration.isApplePayEnabled)
    }

    func testApplePayCountryCode_returnsCountryCode() {
        let configurationJSON = BTJSON(value: [
            "applePay": [ "countryCode": "US" ]
        ])
        let configuration = BTConfiguration(json: configurationJSON)

        XCTAssertEqual(configuration.applePayCountryCode!, "US")
    }

    func testApplePayCurrencyCode_returnsCurrencyCode() {
        let configurationJSON = BTJSON(value: [
            "applePay": [ "currencyCode": "USD" ]
        ])
        let configuration = BTConfiguration(json: configurationJSON)

        XCTAssertEqual(configuration.applePayCurrencyCode!, "USD")
    }

    func testApplePayMerchantIdentifier_returnsMerchantIdentifier() {
        let configurationJSON = BTJSON(value: [
            "applePay": [ "merchantIdentifier": "com.merchant.braintree-unit-tests" ]
        ])
        let configuration = BTConfiguration(json: configurationJSON)

        XCTAssertEqual(configuration.applePayMerchantIdentifier!, "com.merchant.braintree-unit-tests")
    }

    func testApplePaySupportedNetworks_returnsSupportedNetworks() {
        let configurationJSON = BTJSON(value: [
            "applePay": [ "supportedNetworks": ["visa", "mastercard", "amex"] ]
        ])
        let configuration = BTConfiguration(json: configurationJSON)

        XCTAssertEqual(configuration.applePaySupportedNetworks!, [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard, PKPaymentNetwork.amex])
    }

    func testApplePaySupportedNetworks_whenSupportedNetworksIncludesDiscover_returnsSupportedNetworks() {
        let configurationJSON = BTJSON(value: [
            "applePay": [ "supportedNetworks": ["discover"] ]
        ])
        let configuration = BTConfiguration(json: configurationJSON)

        XCTAssertEqual(configuration.applePaySupportedNetworks!, [PKPaymentNetwork.discover])
    }

    func testApplePaySupportedNetworks_doesNotPassesThroughUnknownValuesFromConfiguration() {
        let configurationJSON = BTJSON(value: [
            "applePay": [ "supportedNetworks": ["ChinaUnionPay", "Interac", "PrivateLabel"] ]
        ])
        let configuration = BTConfiguration(json: configurationJSON)

        XCTAssertEqual(configuration.applePaySupportedNetworks!, [])
    }
}
