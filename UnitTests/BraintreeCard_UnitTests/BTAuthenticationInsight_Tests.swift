import XCTest

class BTAuthenticationInsight_Tests: XCTestCase {
    
    func testInitWithJSON_whenJSONKeyIsRegulationEnvironment_setsRegulationEnvironment() {
        let authInsight = BTAuthenticationInsight(json: BTJSON(value: [
            "regulationEnvironment": "unregulated"
            ]))
        
        XCTAssertEqual(authInsight?.regulationEnvironment, "unregulated")
    }
    
    func testInitWithJSON_whenRegulationEnvironmentIsNil_setsRegulationEnvironmentToNil() {
        let authInsight = BTAuthenticationInsight(json: BTJSON(value: [
            "regulationEnvironment": nil
            ]))
        
        XCTAssertNil(authInsight?.regulationEnvironment)
    }
    
    func testInitWithJSON_whenJSONKeyIsCustomerAuthenticationRegulationEnvironment_setsRegulationEnvironment() {
        let authInsight = BTAuthenticationInsight(json: BTJSON(value: [
            "customerAuthenticationRegulationEnvironment": "unregulated"
            ]))
        
        XCTAssertEqual(authInsight?.regulationEnvironment, "unregulated")
    }
    
    func testInitWithJSON_whenRegulationEnvironmentContainsUppercaseLetters_setsLowercasedRegulationEnvironment() {
        let authInsight = BTAuthenticationInsight(json: BTJSON(value: [
            "customerAuthenticationRegulationEnvironment": "UnReGuLaTeD"
            ]))
        
        XCTAssertEqual(authInsight?.regulationEnvironment, "unregulated")
    }
    
    func testInitWithJSON_whenRegulationEnvironmentIsPSDTWO_setsRegulationEnvironmentToPsd2() {
        let authInsight = BTAuthenticationInsight(json: BTJSON(value: [
            "customerAuthenticationRegulationEnvironment": "PSDTWO"
            ]))
        
        XCTAssertEqual(authInsight?.regulationEnvironment, "psd2")
    }
    
    func testInitWithJSON_whenCustomerAuthenticationRegulationEnvironmentIsNil_setsRegulationEnvironmentToNil() {
        let authInsight = BTAuthenticationInsight(json: BTJSON(value: [
            "customerAuthenticationRegulationEnvironment": nil
            ]))
        
        XCTAssertNil(authInsight?.regulationEnvironment)
    }
    
    func testInitWithJSON_whenRegulationEnvironmentKeyIsNotPresent_setsRegulationEnvironmentToNil() {
        let authInsight = BTAuthenticationInsight(json: BTJSON(value: [:]))
        
        XCTAssertNil(authInsight?.regulationEnvironment)
    }
}
