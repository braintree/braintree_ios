import XCTest
@testable import BraintreeCore
@testable import BraintreeVisaCheckout

final class BTVisaCheckoutCardNonce_Tests: XCTestCase {
    
    func testInitializer_assignsAllPropertiesCorrectly() {
        
        let json = BTJSON(value: [
            "userFirstName": "Alice",
            "userLastName": "Smith",
            "userFullName": "Alice Smith",
            "userName": "asmith",
            "userEmail": "alice@example.com"
        ])
        
        let billing = BTVisaCheckoutAddress(json: json)
        let shipping = BTVisaCheckoutAddress(json: json)
        let userData = BTVisaCheckoutUserData(json: json)
        
        let binJson = BTJSON(value: [
            "prepaid": "Yes",
            "healthcare": "No",
            "debit": "Yes",
            "durbinRegulated": "No",
            "commercial": "Yes",
            "payroll": "No",
            "issuingBank": "Test Bank",
            "countryOfIssuance": "US",
            "productId": "G"
        ])
        
        let binData = BTBinData(json: binJson)
        
        let nonce = BTVisaCheckoutNonce(
            nonce: "fake-nonce",
            type: "VisaCheckout",
            lastTwo: "11",
            cardType: "Visa",
            billingAddress: billing,
            shippingAddress: shipping,
            userData: userData,
            callId: "fake-call-id",
            binData: binData,
            isDefault: true
        )
        
        XCTAssertEqual(nonce.nonce, "fake-nonce")
        XCTAssertEqual(nonce.type, "VisaCheckout")
        XCTAssertEqual(nonce.lastTwo, "11")
        XCTAssertEqual(nonce.cardType, "Visa")
        XCTAssertEqual(nonce.callId, "fake-call-id")
        XCTAssertEqual(nonce.isDefault, true)
        XCTAssertEqual(nonce.billingAddress.firstName, "Alice")
        XCTAssertEqual(nonce.shippingAddress.firstName, "Smith")
        XCTAssertEqual(nonce.userData.userEmail, "alice@example.com")
        XCTAssertEqual(nonce.binData.issuingBank, "Test Bank")
    }
}
