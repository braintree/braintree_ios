import XCTest

class BTThreeDSecureInfo_Tests: XCTestCase {

    func testParsesJson() {
        let json = BTJSON(value:
            [
                "cavv": "fake-cavv",
                "dsTransactionId": "fake-txn-id",
                "eciFlag": "07",
                "enrolled": "Y",
                "liabilityShiftPossible": true,
                "liabilityShifted": false,
                "status": "lookup_enrolled",
                "threeDSecureVersion": "2.2.0",
                "xid": "fake-xid"
            ]
        )
        let info = BTThreeDSecureInfo(json: json)

        XCTAssertEqual("fake-cavv", info.cavv)
        XCTAssertEqual("fake-txn-id", info.dsTransactionId)
        XCTAssertEqual("07", info.eciFlag)
        XCTAssertEqual("Y", info.enrolled)
        XCTAssertEqual("lookup_enrolled", info.status)
        XCTAssertEqual("2.2.0", info.threeDSecureVersion)
        XCTAssertEqual("fake-xid", info.xid)
        XCTAssertTrue(info.liabilityShiftPossible)
        XCTAssertFalse(info.liabilityShifted)
        XCTAssertTrue(info.wasVerified)
    }

}

