import XCTest
@testable import BraintreeCore
@testable import BraintreeVisaCheckout

final class BTVisaCheckoutCardNonce_Tests: XCTestCase {
    
    func testInitFromJSON_parsesAllFieldsCorrectly() {
        let json = BTJSON(value: [
            "visaCheckoutCards": [[
                "nonce": "abc123",
                "type": "VisaCheckout",
                "default": true,
                "details": [
                    "lastTwo": "11",
                    "cardType": "Visa"
                ],
                "billingAddress": [
                    "firstName": "Bill"
                ],
                "shippingAddress": [
                    "firstName": "Ship"
                ],
                "userData": [
                    "userFirstName": "Alice",
                    "userLastName": "Smith",
                    "userFullName": "Alice Smith",
                    "userName": "asmith",
                    "userEmail": "alice@example.com"
                ],
                "callId": "call-id-123",
                "binData": [
                    "prepaid": "Yes",
                    "healthcare": "No",
                    "debit": "Yes",
                    "durbinRegulated": "No",
                    "commercial": "Yes",
                    "payroll": "No",
                    "issuingBank": "BankName",
                    "countryOfIssuance": "US",
                    "productId": "G"
                ]
            ]]
        ])

        guard let nonce = BTVisaCheckoutNonce(json: json) else {
            return XCTFail("Expected BTVisaCheckoutNonce to be created")
        }

        XCTAssertEqual(nonce.nonce, "abc123")
        XCTAssertEqual(nonce.type, "Visa")
        XCTAssertEqual(nonce.lastTwo, "11")
        XCTAssertEqual(nonce.callID, "call-id-123")
        XCTAssertEqual(nonce.cardType, "Visa")
        XCTAssertEqual(nonce.isDefault, true)

        XCTAssertEqual(nonce.billingAddress.firstName, "Bill")
        XCTAssertEqual(nonce.shippingAddress.firstName, "Ship")
        XCTAssertEqual(nonce.userData.userEmail, "alice@example.com")
        XCTAssertEqual(nonce.binData.issuingBank, "BankName")
        XCTAssertEqual(nonce.binData.productID, "G")
    }
}
