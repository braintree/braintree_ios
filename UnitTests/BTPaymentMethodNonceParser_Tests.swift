import XCTest

class BTTokenizationParser_Tests: XCTestCase {
    
    var parser : BTPaymentMethodNonceParser = BTPaymentMethodNonceParser()

    func testRegisterType_addsTypeToTypes() {
        parser.registerType("MyType") { _ -> BTPaymentMethodNonce? in return nil}

        XCTAssertTrue(parser.allTypes.contains("MyType"))
    }
    
    func testAllTypes_whenTypeIsNotRegistered_doesntContainType() {
        XCTAssertEqual(parser.allTypes.count, 0)
    }
    
    func testIsTypeAvailable_whenTypeIsRegistered_isTrue() {
        parser.registerType("MyType") { _ -> BTPaymentMethodNonce? in return nil}
        XCTAssertTrue(parser.isTypeAvailable("MyType"))
    }
    
    func testIsTypeAvailable_whenTypeIsNotRegistered_isFalse() {
        XCTAssertFalse(parser.isTypeAvailable("MyType"))
    }

    func testParseJSON_whenTypeIsRegistered_callsParsingBlock() {
        let expectation = expectationWithDescription("Parsing block called")
        parser.registerType("MyType") { _ -> BTPaymentMethodNonce? in
            expectation.fulfill()
            return nil
        }
        parser.parseJSON(BTJSON(), withParsingBlockForType: "MyType")

        waitForExpectationsWithTimeout(3, handler: nil)
    }
    
    func testParseJSON_whenTypeIsNotRegisteredAndJSONContainsNonce_returnsBasicTokenizationObject() {
        let json = BTJSON(value: ["nonce": "valid-nonce",
                                  "description": "My Description"])
        
        let paymentMethodNonce = parser.parseJSON(json, withParsingBlockForType: "MyType")
        
        XCTAssertEqual(paymentMethodNonce?.nonce, "valid-nonce")
        XCTAssertEqual(paymentMethodNonce?.localizedDescription, "My Description")
    }
    
    func testParseJSON_whenTypeIsNotRegisteredAndJSONDoesNotContainNonce_returnsNil() {
        let paymentMethodNonce = parser.parseJSON(BTJSON(value: ["description": "blah"]), withParsingBlockForType: "MyType")
        
       XCTAssertNil(paymentMethodNonce)
    }
}
