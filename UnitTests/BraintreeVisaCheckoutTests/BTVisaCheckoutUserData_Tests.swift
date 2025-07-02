import XCTest

@testable import BraintreeCore
@testable import BraintreeVisaCheckout

final class BTVisaCheckoutUserData_Tests: XCTestCase {

    func testInitWithJSON_assignsAllFieldsCorrectly() {
        let json = BTJSON(value: [
            "userFirstName": "Alice",
            "userLastName": "Smith",
            "userFullName": "Alice Smith",
            "userName": "asmith",
            "userEmail": "alice@example.com"
        ])

        let userData = BTVisaCheckoutUserData(json: json)

        XCTAssertEqual(userData.userFirstName, "Alice")
        XCTAssertEqual(userData.userLastName, "Smith")
        XCTAssertEqual(userData.userFullName, "Alice Smith")
        XCTAssertEqual(userData.username, "asmith")
        XCTAssertEqual(userData.userEmail, "alice@example.com")
    }

    func testInitWithJSON_allFieldsNilIfMissing() {
        let json = BTJSON(value: [:])
        let userData = BTVisaCheckoutUserData(json: json)

        XCTAssertNil(userData.userFirstName)
        XCTAssertNil(userData.userLastName)
        XCTAssertNil(userData.userFullName)
        XCTAssertNil(userData.username)
        XCTAssertNil(userData.userEmail)
    }

    func testUserDataWith_returnsSameAsInit() {
        let json = BTJSON(value: ["userEmail": "test@example.com"])
        let fromFactory = BTVisaCheckoutUserData.userData(with: json)
        let fromInit = BTVisaCheckoutUserData(json: json)

        XCTAssertEqual(fromFactory.userEmail, fromInit.userEmail)
    }
}
