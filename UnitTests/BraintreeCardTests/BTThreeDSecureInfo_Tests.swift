import XCTest
import BraintreeCore
@testable import BraintreeCard

class BTThreeDSecureInfo_Tests: XCTestCase {
    func testParsesJson() {
        let json = BTJSON(value:
                            [
                                "acsTransactionId": "fake-acs-transaction-id",
                                "cavv": "fake-cavv",
                                "dsTransactionId": "fake-txn-id",
                                "eciFlag": "07",
                                "enrolled": "Y",
                                "liabilityShiftPossible": true,
                                "liabilityShifted": false,
                                "paresStatus": "U",
                                "status": "lookup_enrolled",
                                "threeDSecureAuthenticationId" : "3fg8syh4nsmq3nzrmv",
                                "threeDSecureServerTransactionId": "fake-threedsecure-server-transaction-id",
                                "threeDSecureVersion": "2.2.0",
                                "xid": "fake-xid",
                                "authentication": [
                                    "transStatus": "Y",
                                    "transStatusReason": "02"
                                ],
                                "lookup": [
                                    "transStatus": "N",
                                    "transStatusReason": "01"
                                ]
                            ]
        )
        let info = BTThreeDSecureInfo(json: json)
        
        XCTAssertEqual("fake-acs-transaction-id", info.acsTransactionID)
        XCTAssertEqual("fake-cavv", info.cavv)
        XCTAssertEqual("fake-txn-id", info.dsTransactionID)
        XCTAssertEqual("07", info.eciFlag)
        XCTAssertEqual("Y", info.enrolled)
        XCTAssertEqual("U", info.paresStatus)
        XCTAssertEqual("lookup_enrolled", info.status)
        XCTAssertEqual("3fg8syh4nsmq3nzrmv", info.threeDSecureAuthenticationID)
        XCTAssertEqual("fake-threedsecure-server-transaction-id", info.threeDSecureServerTransactionID)
        XCTAssertEqual("2.2.0", info.threeDSecureVersion)
        XCTAssertEqual("fake-xid", info.xid)
        XCTAssertTrue(info.liabilityShiftPossible)
        XCTAssertFalse(info.liabilityShifted)
        XCTAssertTrue(info.wasVerified)
        XCTAssertEqual("Y", info.authenticationTransactionStatus)
        XCTAssertEqual("02", info.authenticationTransactionStatusReason)
        XCTAssertEqual("N", info.lookupTransactionStatus)
        XCTAssertEqual("01", info.lookupTransactionStatusReason)
    }
}
