import XCTest
import BraintreeTestShared

class BTTokenizationService_Tests: XCTestCase {
    var tokenizationService : BTTokenizationService!

    override func setUp() {
        super.setUp()
        tokenizationService = BTTokenizationService()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testRegisterType_addsTypeToTypes() {
        tokenizationService.registerType("MyType") { _,_,_  -> Void in }
        XCTAssertTrue(tokenizationService.allTypes.contains("MyType"))
    }

    func testAllTypes_whenTypeIsNotRegistered_doesntContainType() {
        XCTAssertFalse(tokenizationService.allTypes.contains("MyType"))
    }

    func testIsTypeAvailable_whenTypeIsRegistered_isTrue() {
        tokenizationService.registerType("MyType") { _,_,_  -> Void in }
        XCTAssertTrue(tokenizationService.isTypeAvailable("MyType"))
    }

    func testIsTypeAvailable_whenTypeIsNotRegistered_returnsFalse() {
        XCTAssertFalse(tokenizationService.isTypeAvailable("MyType"))
    }

    func testTokenizeType_whenTypeIsRegistered_callsTokenizationBlock() {
        let expectation = self.expectation(description: "tokenization block called")
        tokenizationService.registerType("MyType") { _,_,_  -> Void in
            expectation.fulfill()
        }

        tokenizationService.tokenizeType("MyType", options: nil, with: BTAPIClient(authorization: "development_testing_integration_merchant_id")!) { _,_  -> Void in
            //nada
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testTokenizeType_whenCalledWithOptions_callsTokenizationBlockAndPassesInOptions() {
        let expectation = self.expectation(description: "tokenization block called")
        let expectedOptions = ["Some Custom Option Key": "The Option Value"]
        tokenizationService.registerType("MyType") { (_, options, _) -> Void in
            XCTAssertEqual(options as! [String : String], expectedOptions)
            expectation.fulfill()
        }

        tokenizationService.tokenizeType("MyType", options: expectedOptions, with:BTAPIClient(authorization: "development_testing_integration_merchant_id")!) { _,_  -> Void in }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testTokenizeType_whenTypeIsNotRegistered_returnsError() {
        let expectation = self.expectation(description: "Callback invoked")
        tokenizationService.tokenizeType("UnknownType", options: nil, with:BTAPIClient(authorization: "development_testing_integration_merchant_id")!) { nonce, error -> Void in
            XCTAssertNil(nonce)
            guard let error = error as NSError? else {return}
            XCTAssertEqual(error.domain, BTTokenizationServiceErrorDomain)
            XCTAssertEqual(error.code, BTTokenizationServiceError.typeNotRegistered.rawValue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler:nil)
    }
}
