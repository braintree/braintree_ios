import XCTest

class BTTokenizationService_Venmo_Tests: XCTestCase {
    func testSingleton_hasVenmoTypeAvailable() {
        let sharedService = BTTokenizationService.shared()

        XCTAssertTrue(sharedService.isTypeAvailable("PayPal"))
    }
}
