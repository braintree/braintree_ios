import XCTest
@testable import BraintreeCore
@testable import BraintreeVisaCheckout

final class BTVisaCheckoutCardNonce_Tests: XCTestCase {
    
    func testInitFromJSON_parsesAllFieldsCorrectly() {
        let json = BTJSON(value: [
            "visaCheckoutCards": [[
                "type": "VisaCheckoutCard",
                "nonce": "123456-12345-12345-a-adfa",
                "description": "ending in ••11",
                "default": false,
                "details": [
                    "cardType": "Visa",
                    "lastTwo": "11"
                ],
                "billingAddress": [
                    "firstName": "billingFirstName",
                    "lastName": "billingLastName",
                    "streetAddress": "billingStreetAddress",
                    "extendedAddress": "billingExtendedAddress",
                    "locality": "billingLocality",
                    "region": "billingRegion",
                    "postalCode": "billingPostalCode",
                    "countryCode": "billingCountryCode",
                    "phoneNumber": "phoneNumber"
                ],
                "shippingAddress": [
                    "firstName": "shippingFirstName",
                    "lastName": "shippingLastName",
                    "streetAddress": "shippingStreetAddress",
                    "extendedAddress": "shippingExtendedAddress",
                    "locality": "shippingLocality",
                    "region": "shippingRegion",
                    "postalCode": "shippingPostalCode",
                    "countryCode": "shippingCountryCode",
                    "phoneNumber": "phoneNumber"
                ],
                "userData": [
                    "userFirstName": "userFirstName",
                    "userLastName": "userLastName",
                    "userFullName": "userFullName",
                    "userName": "userUserName",
                    "userEmail": "userEmail"
                ],
                "callId": "callId",
                "binData": [
                    "prepaid": "Unknown",
                    "healthcare": "Yes",
                    "debit": "No",
                    "durbinRegulated": "Unknown",
                    "commercial": "Unknown",
                    "payroll": "Unknown",
                    "issuingBank": "Unknown",
                    "countryOfIssuance": "Something",
                    "productId": "123"
                ]
            ]]
        ])

        guard let nonce = BTVisaCheckoutNonce(json: json) else {
            return XCTFail("Expected BTVisaCheckoutNonce to be created")
        }

        XCTAssertEqual(nonce.nonce, "123456-12345-12345-a-adfa")
        XCTAssertEqual(nonce.type, "Visa")
        XCTAssertEqual(nonce.lastTwo, "11")
        XCTAssertEqual(nonce.callID, "callId")
        XCTAssertEqual(nonce.cardType, "Visa")
        XCTAssertEqual(nonce.isDefault, false)

        XCTAssertEqual(nonce.billingAddress.firstName, "billingFirstName")
        XCTAssertEqual(nonce.billingAddress.lastName, "billingLastName")
        XCTAssertEqual(nonce.billingAddress.streetAddress, "billingStreetAddress")
        XCTAssertEqual(nonce.billingAddress.extendedAddress, "billingExtendedAddress")
        XCTAssertEqual(nonce.billingAddress.locality, "billingLocality")
        XCTAssertEqual(nonce.billingAddress.region, "billingRegion")
        XCTAssertEqual(nonce.billingAddress.postalCode, "billingPostalCode")
        XCTAssertEqual(nonce.billingAddress.countryCode, "billingCountryCode")
        XCTAssertEqual(nonce.billingAddress.phoneNumber, "phoneNumber")
        
        XCTAssertEqual(nonce.shippingAddress.firstName, "shippingFirstName")
        XCTAssertEqual(nonce.shippingAddress.lastName, "shippingLastName")
        XCTAssertEqual(nonce.shippingAddress.streetAddress, "shippingStreetAddress")
        XCTAssertEqual(nonce.shippingAddress.extendedAddress, "shippingExtendedAddress")
        XCTAssertEqual(nonce.shippingAddress.locality, "shippingLocality")
        XCTAssertEqual(nonce.shippingAddress.region, "shippingRegion")
        XCTAssertEqual(nonce.shippingAddress.postalCode, "shippingPostalCode")
        XCTAssertEqual(nonce.shippingAddress.countryCode, "shippingCountryCode")
        XCTAssertEqual(nonce.shippingAddress.phoneNumber, "phoneNumber")
        
        XCTAssertEqual(nonce.userData.userFirstName, "userFirstName")
        XCTAssertEqual(nonce.userData.userLastName, "userLastName")
        XCTAssertEqual(nonce.userData.userFullName, "userFullName")
        XCTAssertEqual(nonce.userData.username, "userUserName")
        XCTAssertEqual(nonce.userData.userEmail, "userEmail")

        XCTAssertEqual(nonce.binData.prepaid, "Unknown")
        XCTAssertEqual(nonce.binData.healthcare, "Yes")
        XCTAssertEqual(nonce.binData.debit, "No")
        XCTAssertEqual(nonce.binData.durbinRegulated, "Unknown")
        XCTAssertEqual(nonce.binData.commercial, "Unknown")
        XCTAssertEqual(nonce.binData.payroll, "Unknown")
        XCTAssertEqual(nonce.binData.issuingBank, "Unknown")
        XCTAssertEqual(nonce.binData.countryOfIssuance, "Something")
        XCTAssertEqual(nonce.binData.productID, "123")
    }
    
    func testFromJSON_whenNoCallId_createsVisaCheckoutNonceWithEmptyCallId() {

        let visaCheckoutJSON = BTJSON(value: [
            "visaCheckoutCards": [[
                "type": "VisaCheckoutCard",
                "nonce": "123456-12345-12345-a-adfa",
                "description": "ending in ••11",
                "default": false,
                "details": [
                    "cardType": "Visa",
                    "lastTwo": "11"
                ],
                "billingAddress": [
                    "firstName": "billingFirstName",
                    "lastName": "billingLastName",
                    "streetAddress": "billingStreetAddress",
                    "extendedAddress": "billingExtendedAddress",
                    "locality": "billingLocality",
                    "region": "billingRegion",
                    "postalCode": "billingPostalCode",
                    "countryCode": "billingCountryCode",
                    "phoneNumber": "phoneNumber"
                ],
                "shippingAddress": [
                    "firstName": "shippingFirstName",
                    "lastName": "shippingLastName",
                    "streetAddress": "shippingStreetAddress",
                    "extendedAddress": "shippingExtendedAddress",
                    "locality": "shippingLocality",
                    "region": "shippingRegion",
                    "postalCode": "shippingPostalCode",
                    "countryCode": "shippingCountryCode",
                    "phoneNumber": "phoneNumber"
                ],
                "userData": [
                    "userFirstName": "userFirstName",
                    "userLastName": "userLastName",
                    "userFullName": "userFullName",
                    "userName": "userUserName",
                    "userEmail": "userEmail"
                ],
                "binData": [
                    "prepaid": "Unknown",
                    "healthcare": "Yes",
                    "debit": "No",
                    "durbinRegulated": "Unknown",
                    "commercial": "Unknown",
                    "payroll": "Unknown",
                    "issuingBank": "Unknown",
                    "countryOfIssuance": "Something",
                    "productId": "123"
                ]
            ]]
        ])

        let visaCheckoutNonce = BTVisaCheckoutNonce(json: visaCheckoutJSON)

        XCTAssertEqual(visaCheckoutNonce?.callID, "")
    }
}
