import XCTest

class BTPreferredPaymentMethodsResult_Tests: XCTestCase {
    
    func testInitWithJSON_whenPayPalIsPreferred_setsIsPayPalPreferredToTrue() {
        let json = BTJSON(value: ["data": ["clientConfiguration": ["paypal": ["preferredPaymentMethod": true]]]])
        
        let result = BTPreferredPaymentMethodsResult(json: json)
        XCTAssertTrue(result.isPayPalPreferred)
    }
    
    func testInitWithJSON_whenPayPalIsNotPreferred_setsIsPayPalPreferredToFalse() {
        let json = BTJSON(value: ["data": ["clientConfiguration": ["paypal": ["preferredPaymentMethod": false]]]])
        
        let result = BTPreferredPaymentMethodsResult(json: json)
        XCTAssertFalse(result.isPayPalPreferred)
    }
    
    func testInitWithJSON_whenJSONDoesNotHaveExpectedStructure_setsIsPayPalPreferredToFalse() {
        let json = BTJSON(value: ["unexpected": "json!"])
        
        let result = BTPreferredPaymentMethodsResult(json: json)
        XCTAssertFalse(result.isPayPalPreferred)
    }
    
    func testInitWithJSON_whenJSONIsNil_setsIsPayPalPreferredToFalse() {
        let result = BTPreferredPaymentMethodsResult(json: nil)
        XCTAssertFalse(result.isPayPalPreferred)
    }
}
