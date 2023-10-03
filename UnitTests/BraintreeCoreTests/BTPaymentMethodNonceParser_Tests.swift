import XCTest
@testable import BraintreeCore

class BTPaymentMethodNonceParser_Tests: XCTestCase {
    var parser: BTPaymentMethodNonceParser = BTPaymentMethodNonceParser()

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

        let _ = parser.parseJSON(BTJSON(), withParsingBlockForType: "MyType")

        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testParseJSON_whenTypeIsNotRegisteredAndJSONContainsNonce_returnsBasicTokenizationObject() {
        let json = BTJSON(value: ["nonce": "valid-nonce"])

        let paymentMethodNonce = parser.parseJSON(json, withParsingBlockForType: "MyType")
        
        XCTAssertEqual(paymentMethodNonce?.nonce, "valid-nonce")
    }
    
    func testParseJSON_whenTypeIsNotRegisteredAndJSONDoesNotContainNonce_returnsNil() {
        let paymentMethodNonce = parser.parseJSON(BTJSON(value: ["details": [] as [Any?]]), withParsingBlockForType: "MyType")
        
       XCTAssertNil(paymentMethodNonce)
    }

    func testSharedParser_whenTypeIsUnknown_returnsBasePaymentMethodNonce() {
        let sharedParser = BTPaymentMethodNonceParser.shared
        let JSON = BTJSON(value: [
            "consumed": false,
            "description": "Some thing",
            "details": [] as [Any?],
            "isLocked": false,
            "nonce": "a-nonce",
            "type": "asdfasdfasdf",
            "default": true
            ] as [String: Any])

        let unknownNonce = sharedParser.parseJSON(JSON, withParsingBlockForType: "asdfasdfasdf")!

        XCTAssertEqual(unknownNonce.nonce, "a-nonce")
        XCTAssertEqual(unknownNonce.type, "Unknown")
        XCTAssertTrue(unknownNonce.isDefault)
    }

    func testSharedParser_whenTypeIsApplePayCard_returnsApplePayType() {
        let sharedParser = BTPaymentMethodNonceParser.shared
        let applePayCard = BTJSON(value: [
            "consumed": false,
            "details": ["cardType": "American Express"],
            "isLocked": false,
            "nonce": "a-nonce",
            "securityQuestions": [] as [Any],
            "type": "ApplePayCard",
        ] as [String: Any])

        let applePayCardNonce = sharedParser.parseJSON(applePayCard, withParsingBlockForType: "ApplePayCard")

        XCTAssertEqual(applePayCardNonce?.nonce, "a-nonce")
        XCTAssertEqual(applePayCardNonce?.type, "American Express")
    }

    func testSharedParser_whenTypeIsCreditCard_returnsCardType() {
        let sharedParser = BTPaymentMethodNonceParser.shared

        let creditCardJSON = BTJSON(value: [
            "consumed": false,
            "description": "ending in 31",
            "details": [
                "cardType": "American Express",
                "lastTwo": "31",
            ],
            "isLocked": false,
            "nonce": "0099b1d0-7a1c-44c3-b1e4-297082290bb9",
            "securityQuestions": ["cvv"],
            "threeDSecureInfo": NSNull(),
            "type": "CreditCard",
            "default": true
        ] as [String: Any])

        let cardNonce = sharedParser.parseJSON(creditCardJSON, withParsingBlockForType:"CreditCard")!

        XCTAssertEqual(cardNonce.nonce, "0099b1d0-7a1c-44c3-b1e4-297082290bb9")
        XCTAssertEqual(cardNonce.type, "AMEX")
        XCTAssertTrue(cardNonce.isDefault)
    }

    func testSharedParser_whenTypeIsVenmo_returnsVenmoType() {
        let sharedParser = BTPaymentMethodNonceParser.shared

        let venmoAccountJSON = BTJSON(value: [
            "consumed": false,
            "description": "VenmoAccount",
            "details": ["username": "jane.doe.username@example.com"],
            "isLocked": false,
            "nonce": "a-nonce",
            "securityQuestions": [] as [Any],
            "type": "VenmoAccount",
            "default": true
        ] as [String: Any])

        let venmoAccountNonce = sharedParser.parseJSON(venmoAccountJSON, withParsingBlockForType: "VenmoAccount")

        XCTAssertEqual(venmoAccountNonce?.nonce, "a-nonce")
        XCTAssertEqual(venmoAccountNonce?.type, "Venmo")
    }

    func testSharedParser_whenTypeIsPayPal_returnsPayPalType() {
        let sharedParser = BTPaymentMethodNonceParser.shared

        let payPalAccountJSON = BTJSON(value: [
            "consumed": false,
            "description": "jane.doe@example.com",
            "details": ["email": "jane.doe@example.com"],
            "isLocked": false,
            "nonce": "a-nonce",
            "securityQuestions": [] as [Any],
            "type": "PayPalAccount",
            "default": true
        ] as [String: Any])

        let payPalAccountNonce = sharedParser.parseJSON(payPalAccountJSON, withParsingBlockForType: "PayPalAccount")

        XCTAssertEqual(payPalAccountNonce?.nonce, "a-nonce")
        XCTAssertEqual(payPalAccountNonce?.type, "PayPal")
    }
}
