import XCTest

class BTPreferredPaymentMethodsResult_Tests: XCTestCase {
    
    func testInitWithJSON_whenAPIDetectedPayPalPreferredTrue_setsPayPalPreferredToTrue() {
        let jsonString =
            """
            {
                "data": {
                    "preferredPaymentMethods": {
                        "paypalPreferred": true
                    }
                }
            }
            """
        
        let json = BTJSON(data: jsonString.data(using: String.Encoding.utf8)!)
        let result = BTPreferredPaymentMethodsResult(json: json, venmoInstalled: false)
        XCTAssertTrue(result.isPayPalPreferred)
    }
    
    func testInitWithJSON_whenAPIDetectedPayPalNotPreferred_setsPayPalPreferredToFalse() {
        let jsonString =
            """
            {
                "data": {
                    "preferredPaymentMethods": {
                        "paypalPreferred": false
                    }
                }
            }
            """
        
        let json = BTJSON(data: jsonString.data(using: String.Encoding.utf8)!)
        let result = BTPreferredPaymentMethodsResult(json: json, venmoInstalled: false)
        XCTAssertFalse(result.isPayPalPreferred)
    }

    func testInitWithJSON_whenVenmoAppIsInstalled_setsVenmoPreferredToTrue() {
        let result = BTPreferredPaymentMethodsResult(json: nil, venmoInstalled: true)
        XCTAssertTrue(result.isVenmoPreferred)
    }

    func testInitWithJSON_whenVenmoAppIsNotInstalled_setsVenmoPreferredToFalse() {
        let result = BTPreferredPaymentMethodsResult(json: nil, venmoInstalled: false)
        XCTAssertFalse(result.isVenmoPreferred)
    }
    
    func testInitWithJSON_whenJSONDoesNotHaveExpectedStructure_setsPayPalPreferredToFalse() {
        let json = BTJSON(value: ["unexpected": "json!"])
        
        let result = BTPreferredPaymentMethodsResult(json: json, venmoInstalled: false)
        XCTAssertFalse(result.isPayPalPreferred)
    }
    
    func testInitWithJSON_whenJSONIsNil_setsPayPalPreferredToFalse() {
        let result = BTPreferredPaymentMethodsResult(json: nil, venmoInstalled: false)
        XCTAssertFalse(result.isPayPalPreferred)
    }
}
