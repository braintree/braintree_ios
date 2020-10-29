import XCTest

class BTTokenizationService_PayPal_Tests: XCTestCase {
    func testSingleton_hasPayPalTypeAvailable() {
        let sharedService = BTTokenizationService.shared()

        XCTAssertTrue(sharedService.isTypeAvailable("PayPal"))
    }
}
