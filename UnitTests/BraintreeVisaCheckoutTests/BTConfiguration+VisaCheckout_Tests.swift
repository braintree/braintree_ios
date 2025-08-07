import XCTest
import VisaCheckoutSDK
import BraintreeTestShared
@testable import BraintreeCore
@testable import BraintreeVisaCheckout

class BTConfiguration_VisaCheckoutTests: XCTestCase {
    
    func testIsVisaCheckoutEnabled_whenVisaCheckoutEmptyJSONExists_returnsFalse() {
        let configurationJSON = BTJSON(value: [
            "visaCheckout": [:]
        ])
        let configuration = BTConfiguration(json: configurationJSON)
        
        XCTAssertFalse(configuration.isVisaCheckoutEnabled)
    }
    
    func testIsVisaCheckoutEnabled_whenVisaCheckoutFromConfigurationJSONExists_returnsTrue() {
        let configurationJSON = BTJSON(value: [
            "visaCheckout": [
                "apiKey": "apikey"
            ]
        ])
        let configuration = BTConfiguration(json: configurationJSON)
        
        XCTAssertTrue(configuration.isVisaCheckoutEnabled)
    }
    
    func testIsVisaCheckoutEnabled_whenVisaCheckoutFromConfigurationJSONIsMissing() {
        let configurationJSON = BTJSON(value: [:])
        let configuration = BTConfiguration(json: configurationJSON)
        
        XCTAssertFalse(configuration.isVisaCheckoutEnabled)
    }
    
    func testVisaCheckoutSupportedNetworks_returnsSupportedNetworks() {
        let configurationJSON = BTJSON(value: [
            "visaCheckout": [
                "supportedCardTypes": [
                    "Visa",
                    "MasterCard",
                    "American Express",
                    "Discover"
                ]
            ]
        ])
        let configuration = BTConfiguration(json: configurationJSON)
        
        XCTAssertEqual(configuration.acceptedCardBrands, [CardBrand.visa.rawValue, CardBrand.mastercard.rawValue, CardBrand.amex.rawValue, CardBrand.discover.rawValue])
    }
    
    func testVisaCheckoutSupportedNetworks_whenSupportedCardTypesContainsUnknownNetworks_doesNotIncludeThem() {
        let configurationJSON = BTJSON(value: [
            "visaCheckout": [
                "supportedCardTypes": [
                    "Visa",
                    "MasterCard",
                    "American Express",
                    "Discover",
                    "MysteryCard",
                    "Braintree Express"
                ]
            ]
        ])
        let configuration = BTConfiguration(json: configurationJSON)
        
        XCTAssertEqual(configuration.acceptedCardBrands, [CardBrand.visa.rawValue, CardBrand.mastercard.rawValue, CardBrand.amex.rawValue, CardBrand.discover.rawValue])
    }
    
    func testVisaCheckoutSupportedNetworks_whenSupportedCardTypesIsMissing_returnsEmptyList() {
        let configurationJSON = BTJSON(value: [:])
        let configuration = BTConfiguration(json: configurationJSON)
        
        XCTAssertEqual(configuration.acceptedCardBrands, [])
    }
    
    func testVisaCheckoutAPIKey_whenAPIKeyIsMissing_returnsNil() {
        let configurationJSON = BTJSON(value: [:])
        let configuration = BTConfiguration(json: configurationJSON)
        
        XCTAssertNil(configuration.visaCheckoutAPIKey)
    }
    
    func testVisaCheckoutAPIKey_returnsAPIKey() {
        let configurationJSON = BTJSON(value: [
            "visaCheckout": [
                "apiKey": "my-visa-checkout-api-key"
            ]
        ])
        let configuration = BTConfiguration(json: configurationJSON)
        
        XCTAssertEqual(configuration.visaCheckoutAPIKey, "my-visa-checkout-api-key")
    }
    
    func testVisaCheckoutExternalClientId_whenExternalClientIdIsMissing_returnsNil() {
        let configurationJSON = BTJSON(value: [:])
        let configuration = BTConfiguration(json: configurationJSON)
        
        XCTAssertNil(configuration.visaCheckoutExternalClientID)
    }
    
    func testVisaCheckoutExternalClientId_returnsExternalClientId() {
        let configurationJSON = BTJSON(value: [
            "visaCheckout": [
                "externalClientId": "my-visa-checkout-external-client-id"
            ]
        ])
        let configuration = BTConfiguration(json: configurationJSON)
        
        XCTAssertEqual(configuration.visaCheckoutExternalClientID, "my-visa-checkout-external-client-id")
    }
}
