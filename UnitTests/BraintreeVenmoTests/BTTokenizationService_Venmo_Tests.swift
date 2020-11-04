import XCTest
import BraintreeTestShared

class BTTokenizationService_Venmo_Tests: XCTestCase {
    func testSingleton_hasVenmoTypeAvailable() {
        let sharedService = BTTokenizationService.shared()

        XCTAssertTrue(sharedService.isTypeAvailable("Venmo"))
    }
}
