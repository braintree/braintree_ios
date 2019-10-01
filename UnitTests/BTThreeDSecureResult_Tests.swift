import XCTest

class BTThreeDSecureResult_Tests: XCTestCase {
    
    func testInitWithJSON_whenAuthenticationCompletesSuccessfully() {
        let json = BTJSON(value:
            [
                "paymentMethod" : [
                    "binData" : [
                        "commercial" : "Unknown",
                        "countryOfIssuance" : "Unknown",
                        "debit" : "Unknown",
                        "durbinRegulated" : "Unknown",
                        "healthcare" : "Unknown",
                        "issuingBank" : "Unknown",
                        "payroll" : "Unknown",
                        "prepaid" : "Unknown",
                        "productId" : "Unknown",
                    ],
                    "consumed" : 0,
                    "description" : "ending in 91",
                    "details" : [
                        "bin" : 400000,
                        "cardType" : "Visa",
                        "expirationMonth" : 01,
                        "expirationYear" : 22,
                        "lastFour" : 1091,
                        "lastTwo" : 91,
                    ],
                    "nonce" : "dbc6767e-a1c9-095e-59ba-90cb7716f921",
                    "threeDSecureInfo" : [
                        "acsTransactionId" : "9989d175-a56f-42df-b595-26eb4456f72a",
                        "authentication" : [
                            "transStatus" : "Y",
                            "transStatusReason" : nil,
                        ],
                        "cavv" : "MTIzNDU2Nzg5MDEyMzQ1Njc4OTA=",
                        "dsTransactionId" : "a873de57-6821-4735-ba10-f53bb9baecf7",
                        "eciFlag" : 05,
                        "enrolled" : "Y",
                        "liabilityShiftPossible" : true,
                        "liabilityShifted" : true,
                        "lookup" : [
                            "transStatus" : "C",
                            "transStatusReason" : "<null>",
                        ],
                        "paresStatus" : "Y",
                        "status" : "authenticate_successful",
                        "threeDSecureServerTransactionId" : "6482b0d3-cd94-4e27-a058-12d2ad4237b2",
                        "threeDSecureVersion" : "2.1.0",
                        "xid" : nil,
                    ],
                    "type" : "CreditCard",
                ],
                "threeDSecureInfo" : [
                    "liabilityShiftPossible" : true,
                    "liabilityShifted" : true,
                ]
            ])
        
        let threeDSecureResult = BTThreeDSecureResult(json: json)!
        
        XCTAssertTrue(threeDSecureResult.success)
        XCTAssertTrue(threeDSecureResult.liabilityShifted)
        XCTAssertTrue(threeDSecureResult.liabilityShiftPossible)
        XCTAssertNotNil(threeDSecureResult.tokenizedCard)
        XCTAssertNil(threeDSecureResult.errorMessage)
    }
    
    func testInitWithJSON_whenCustomerFailsAuthenticationChallenge_v1() {
        let json = BTJSON(value:
            [
                "error" : [
                    "message" : "Failed to authenticate, please try a different form of payment."
                ],
                "success": false,
                "threeDSecureInfo" : [
                    "liabilityShiftPossible" : true,
                    "liabilityShifted" : false,
                ]
            ])
        
        let threeDSecureResult = BTThreeDSecureResult(json: json)!
        
        XCTAssertFalse(threeDSecureResult.success)
        XCTAssertFalse(threeDSecureResult.liabilityShifted)
        XCTAssertTrue(threeDSecureResult.liabilityShiftPossible)
        XCTAssertNil(threeDSecureResult.tokenizedCard)
        XCTAssertEqual("Failed to authenticate, please try a different form of payment.", threeDSecureResult.errorMessage)
    }
    
    func testInitWithJSON_whenCustomerFailsAuthenticationChallenge_v2() {
        let json = BTJSON(value:
            [
                "errors" : [
                    [
                        "attribute" : "three_d_secure_token",
                        "code" : 81571,
                        "message" : "Failed to authenticate, please try a different form of payment.",
                        "model" : "transaction",
                        "type" : "user",
                    ]
                ],
                "threeDSecureInfo" : [
                    "liabilityShiftPossible" : true,
                    "liabilityShifted" : false,
                ]
            ])
        
        let threeDSecureResult = BTThreeDSecureResult(json: json)!
        
        XCTAssertFalse(threeDSecureResult.success)
        XCTAssertFalse(threeDSecureResult.liabilityShifted)
        XCTAssertTrue(threeDSecureResult.liabilityShiftPossible)
        XCTAssertNil(threeDSecureResult.tokenizedCard)
        XCTAssertEqual("Failed to authenticate, please try a different form of payment.", threeDSecureResult.errorMessage)
    }
}
