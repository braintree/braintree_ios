import XCTest

class BTPayPalCreditFinancingAmount_Tests: XCTestCase {

    func testInit_setsCurrencyAndAmount() {
        let jsonString =
        """
        {
            "currency": "USD",
            "value": "100"
        }
        """

        let json = BTJSON(data: jsonString.data(using: .utf8)!)
        let financingAmount = BTPayPalCreditFinancingAmount(json: json)
        XCTAssertEqual(financingAmount?.currency, "USD")
        XCTAssertEqual(financingAmount?.value, "100")
    }
}
