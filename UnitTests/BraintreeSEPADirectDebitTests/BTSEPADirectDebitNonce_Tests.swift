import XCTest
import BraintreeCore
@testable import BraintreeSEPADirectDebit

class BTSEPADirectDebitNonce_Tests: XCTestCase {

    func testSEPADebitNonceWithJSON_createsSEPADebitNonceWithExpectedValues() {
        let sepaDebitNonce = BTSEPADirectDebitNonce(
            json: BTJSON(
                value: [
                    "type": "SEPADebit",
                    "nonce": "1194c322-9763-08b7-4777-0b9b5e5cc3e4",
                    "description": "SEPA Debit",
                    "consumed": false,
                    "details": [
                        "last4": "1234",
                        "customerId": "a-customer-id",
                        "mandateType": "ONE_OFF"
                    ]
                ]
            )
        )

        XCTAssertEqual(sepaDebitNonce?.nonce, "1194c322-9763-08b7-4777-0b9b5e5cc3e4")
        XCTAssertEqual(sepaDebitNonce?.ibanLastFour, "1234")
        XCTAssertEqual(sepaDebitNonce?.customerID, "a-customer-id")
        XCTAssertEqual(sepaDebitNonce?.mandateType, BTSEPADirectDebitMandateType.oneOff)
    }
}
