import XCTest

class BTPaymentMethodNonceParser_Tests: XCTestCase {
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
        let expectation = self.expectation(description: "Parsing block called")
        parser.registerType("MyType") { _ -> BTPaymentMethodNonce? in
            expectation.fulfill()
            return nil
        }
        parser.parseJSON(BTJSON(), withParsingBlockForType: "MyType")

        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testParseJSON_whenTypeIsNotRegisteredAndJSONContainsNonce_returnsBasicTokenizationObject() {
        let json = BTJSON(value: ["nonce": "valid-nonce"])

        let paymentMethodNonce = parser.parseJSON(json, withParsingBlockForType: "MyType")
        
        XCTAssertEqual(paymentMethodNonce?.nonce, "valid-nonce")
    }
    
    func testParseJSON_whenTypeIsNotRegisteredAndJSONDoesNotContainNonce_returnsNil() {
        let paymentMethodNonce = parser.parseJSON(BTJSON(value: ["details": []]), withParsingBlockForType: "MyType")
        
       XCTAssertNil(paymentMethodNonce)
    }

    func testSharedParser_whenTypeIsUnknown_returnsBasePaymentMethodNonce() {
        let sharedParser = BTPaymentMethodNonceParser.shared()
        let JSON = BTJSON(value: [
            "consumed": false,
            "description": "Some thing",
            "details": [],
            "isLocked": false,
            "nonce": "a-nonce",
            "type": "asdfasdfasdf",
            "default": true
            ])

        let unknownNonce = sharedParser.parseJSON(JSON, withParsingBlockForType: "asdfasdfasdf")!

        XCTAssertEqual(unknownNonce.nonce, "a-nonce")
        XCTAssertEqual(unknownNonce.type, "Unknown")
        XCTAssertTrue(unknownNonce.isDefault)
    }
}
