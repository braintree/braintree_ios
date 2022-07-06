
import XCTest
import Security
@testable import BraintreeCoreSwift

class BTKeychain_Tests: XCTestCase {
    
    func testKeychainForKey_isCorrectFormat() {
        let expectedResult = "com.braintreepayments.Braintree-API.foo"
        let result = BTKeychain.keychainForKey("foo")
        XCTAssertEqual(expectedResult, result)
    }
}
