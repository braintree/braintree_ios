import XCTest

@testable import BraintreeCore
@testable import BraintreeVisaCheckout

final class BTVisaCheckoutUserDataTests: XCTestCase {

    func testInitWithJSON_assignsAllFieldsCorrectly() {
        let json = BTJSON(value: [
            "userFirstName": "Alice",
            "userLastName": "Smith",
            "userFullName": "Alice Smith",
            "userName": "asmith",
            "userEmail": "alice@example.com"
        ])

        let userData = BTVisaCheckoutUserData(json: json)

        XCTAssertEqual(userData.firstName, "Alice")
        XCTAssertEqual(userData.lastName, "Smith")
        XCTAssertEqual(userData.fullName, "Alice Smith")
        XCTAssertEqual(userData.username, "asmith")
        XCTAssertEqual(userData.email, "alice@example.com")
    }

    func testInitWithJSON_allFieldsNilIfMissing() {
        let json = BTJSON(value: [:])
        let userData = BTVisaCheckoutUserData(json: json)

        XCTAssertNil(userData.firstName)
        XCTAssertNil(userData.lastName)
        XCTAssertNil(userData.fullName)
        XCTAssertNil(userData.username)
        XCTAssertNil(userData.email)
    }

    func testUserDataWith_returnsSameAsInit() {
        let json = BTJSON(value: ["userEmail": "test@example.com"])
        let fromFactory = BTVisaCheckoutUserData.userData(with: json)
        let fromInit = BTVisaCheckoutUserData(json: json)

        XCTAssertEqual(fromFactory.email, fromInit.email)
    }
}
