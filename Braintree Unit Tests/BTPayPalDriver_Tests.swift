import XCTest
import Braintree

class BTPayPalDriver_Tests: XCTestCase {
    func testAuthorizePayPal() {
        let expectation = self.expectationWithDescription("Tokenize Card")
        let configuration = BTConfiguration(key: "CLIENT_KEY")
        let payPalDriver = BTPayPalDriver(configuration: configuration, apiClient: FakeAPIClient())

        payPalDriver.authorizeAccountWithCompletion { (tokenizedPayPalAccount, error) -> Void in
            XCTAssertNotNil(tokenizedPayPalAccount.paymentMethodNonce)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        self.waitForExpectationsWithTimeout(2, handler: nil)
    }
}
