import XCTest
@testable import BraintreeCore

class BTBinData_Tests: XCTestCase {
    func testBinData_withCompleteJSON() {
        let json = BTJSON(value: [
            "description": "Visa ending in 11",
            "details": [
                "cardType": "Visa",
                "lastTwo": "11",
            ],
            "binData": [
                "prepaid": "Yes",
                "healthcare": "Yes",
                "debit": "No",
                "durbinRegulated": "No",
                "commercial": "Yes",
                "payroll": "No",
                "issuingBank": "US",
                "countryOfIssuance": "Something",
                "productId": "123"
            ],
            "nonce": "fake-nonce",
        ] as [String: Any])
        let binData = BTBinData(json: json["binData"])

        XCTAssertEqual(binData.prepaid, "Yes")
        XCTAssertEqual(binData.healthcare, "Yes")
        XCTAssertEqual(binData.debit, "No")
        XCTAssertEqual(binData.durbinRegulated, "No")
        XCTAssertEqual(binData.commercial, "Yes")
        XCTAssertEqual(binData.payroll, "No")
        XCTAssertEqual(binData.issuingBank, "US")
        XCTAssertEqual(binData.countryOfIssuance, "Something")
        XCTAssertEqual(binData.productID, "123")
    }
    
    func testBinData_withEmptyJSON() {
        let json = BTJSON(value: [
            "some": "value"
            ])
        let binData = BTBinData(json: json["binData"])

        XCTAssertEqual(binData.prepaid, "Unknown")
        XCTAssertEqual(binData.healthcare, "Unknown")
        XCTAssertEqual(binData.debit, "Unknown")
        XCTAssertEqual(binData.durbinRegulated, "Unknown")
        XCTAssertEqual(binData.commercial, "Unknown")
        XCTAssertEqual(binData.payroll, "Unknown")
        XCTAssertEqual(binData.issuingBank, "")
        XCTAssertEqual(binData.countryOfIssuance, "")
        XCTAssertEqual(binData.productID, "")
    }
    
    func testBinData_withPartialJSON() {
        let binData = BTBinData(json: BTJSON(value: [
            "prepaid": "Yes",
            "healthcare": "Yes",
            "countryOfIssuance": "Something",
            "productId": "123"
            ]))

        XCTAssertEqual(binData.prepaid, "Yes")
        XCTAssertEqual(binData.healthcare, "Yes")
        XCTAssertEqual(binData.debit, "Unknown")
        XCTAssertEqual(binData.durbinRegulated, "Unknown")
        XCTAssertEqual(binData.commercial, "Unknown")
        XCTAssertEqual(binData.payroll, "Unknown")
        XCTAssertEqual(binData.issuingBank, "")
        XCTAssertEqual(binData.countryOfIssuance, "Something")
        XCTAssertEqual(binData.productID, "123")
    }
    
}
