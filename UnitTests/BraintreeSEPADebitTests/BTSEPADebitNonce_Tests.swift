import XCTest
import BraintreeCore
@testable import BraintreeSEPADebit

class BTPSEPADebitNonce_Tests: XCTestCase {

    func testSEPADebitNonceWithJSON_createsSEPADebitNonceWithExpectedValues() {
        let sepaDebitNonce = BTSEPADebitNonce(
            json: BTJSON(
                value: [
                    "type": "SEPADebit",
                    "nonce": "1194c322-9763-08b7-4777-0b9b5e5cc3e4",
                    "description": "SEPA Debit",
                    "consumed": false,
                    "details": [
                        "ibanLastChars": "1234",
                        "customerId": "a-customer-id",
                        "mandateType": "ONE_OFF"
                    ]
                ]
            )
        )

        XCTAssertEqual(sepaDebitNonce.nonce, "1194c322-9763-08b7-4777-0b9b5e5cc3e4")
        XCTAssertEqual(sepaDebitNonce.ibanLastFour, "1234")
        XCTAssertEqual(sepaDebitNonce.customerID, "a-customer-id")
        XCTAssertEqual(sepaDebitNonce.mandateType, BTSEPADebitMandateType.oneOff)
    }
}
