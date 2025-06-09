import XCTest
import BraintreeCore


final class BTVisaCheckoutClient_Tests: XCTestCase {

    func testBTVisaCheckoutAddress_initializesAllPropertiesCorrectly() {
        let json: BTJSON = BTJSON(value: [
            "firstName": "John",
            "lastName": "Doe",
            "streetAddress": "123 Main St",
            "extendedAddress": "Apt 4B",
            "locality": "San Francisco",
            "region": "CA",
            "postalCode": "94105",
            "countryCode": "US",
            "phoneNumber": "1234567890"
        ])

        let address = BTVisaCheckoutAddress(json: json)
        

        XCTAssertEqual(address.firstName, "John")
        XCTAssertEqual(address.lastName, "Doe")
        XCTAssertEqual(address.streetAddress, "123 Main St")
        XCTAssertEqual(address.extendedAddress, "Apt 4B")
        XCTAssertEqual(address.locality, "San Francisco")
        XCTAssertEqual(address.region, "CA")
        XCTAssertEqual(address.postalCode, "94105")
        XCTAssertEqual(address.countryCode, "US")
        XCTAssertEqual(address.phoneNumber, "1234567890")
    }

    func testBTVisaCheckoutAddress_withMissingValues_returnsNilProperties() {
        let json = BTJSON(value: [:])
        let address = BTVisaCheckoutAddress(json: json)

        XCTAssertNil(address.firstName)
        XCTAssertNil(address.lastName)
        XCTAssertNil(address.streetAddress)
        XCTAssertNil(address.extendedAddress)
        XCTAssertNil(address.locality)
        XCTAssertNil(address.region)
        XCTAssertNil(address.postalCode)
        XCTAssertNil(address.countryCode)
        XCTAssertNil(address.phoneNumber)
    }

    func testAddressFactoryMethod_createsEquivalentInstance() {
        let json = BTJSON(value: ["firstName": "Alice"])
        let address = BTVisaCheckoutAddress.address(with: json)

        XCTAssertEqual(address.firstName, "Alice")
        XCTAssertNil(address.lastName)  // not included in JSON
    }
}
