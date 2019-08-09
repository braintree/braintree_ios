import XCTest

class BTThreeDSecureResult_Tests: XCTestCase {

    func testResult_threeDSecureV2Success_initializesAllProperties() {
        let resultBody = [
            "paymentMethod": [
                "type": "credit_card",
                "nonce": "fake-nonce",
                "threeDSecureInfo": [
                    "liabilityShifted": true,
                    "liabilityShiftPossible": true
                ],
            ],
            "threeDSecureInfo": [
                "liabilityShifted": true,
                "liabilityShiftPossible": true
            ]
        ] as [String : Any]

        let resultJSON = BTJSON(value: resultBody)

        guard let result = BTThreeDSecureResult(json: resultJSON) else {
            XCTFail()
            return
        }

        XCTAssertTrue(result.success)
        XCTAssertNil(result.errorMessage)
        XCTAssertTrue(result.liabilityShifted)
        XCTAssertTrue(result.liabilityShiftPossible)
        XCTAssertNotNil(result.tokenizedCard)
    }

    func testResult_threeDSecureV1Success_initializesAllProperties() {
        let resultBody = [
            "paymentMethod": [
                "type": "CreditCard",
                "nonce": "f648f33b-8b61-0855-52bd-a78d50fc977e",
                "threeDSecureInfo": [
                    "liabilityShifted": true,
                    "liabilityShiftPossible": true
                ]
            ],
            "threeDSecureInfo": [
                "liabilityShifted": true,
                "liabilityShiftPossible": true
            ],
            "success": true
        ] as [String : Any]

        let resultJSON = BTJSON(value: resultBody)

        guard let result = BTThreeDSecureResult(json: resultJSON) else {
            XCTFail()
            return
        }

        XCTAssertTrue(result.success)
        XCTAssertNil(result.errorMessage)
        XCTAssertTrue(result.liabilityShifted)
        XCTAssertTrue(result.liabilityShiftPossible)
        XCTAssertNotNil(result.tokenizedCard)
    }

    func testResult_threeDSecureV2Error_initializesProperties() {
        let resultBody = [
            "errors": [
                [
                    "message": "error_message"
                ]
            ],
            "threeDSecureInfo": [
                "liabilityShiftPossible": true,
                "liabilityShifted" : false
            ],
        ] as [String : Any]

        let resultJSON = BTJSON(value: resultBody)

        guard let result = BTThreeDSecureResult(json: resultJSON) else {
            XCTFail()
            return
        }

        XCTAssertFalse(result.success)
        XCTAssertEqual(result.errorMessage, "error_message")
        XCTAssertFalse(result.liabilityShifted)
        XCTAssertTrue(result.liabilityShiftPossible)
        XCTAssertNil(result.tokenizedCard)
    }

    func testResult_threeDSecureV1Error__initializesProperties() {
        let resultBody = [
            "error": [
                "message": "error_message",
            ],
            "success": false,
            "threeDSecureInfo": [
                "liabilityShiftPossible": true,
                "liabilityShifted" : false
            ],
        ] as [String : Any]

        let resultJSON = BTJSON(value: resultBody)

        guard let result = BTThreeDSecureResult(json: resultJSON) else {
            XCTFail()
            return
        }

        XCTAssertFalse(result.success)
        XCTAssertEqual(result.errorMessage, "error_message")
        XCTAssertFalse(result.liabilityShifted)
        XCTAssertTrue(result.liabilityShiftPossible)
        XCTAssertNil(result.tokenizedCard)
    }
}
