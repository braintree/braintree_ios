import XCTest

class BTAmericanExpressClient_Tests: XCTestCase {

    func testGetRewardsBalance_returnsInvalidParametersErrorWhenNonceNotPresent() {
        let expectation = self.expectation(description: "Options Error")
        let fakeHTTP = FakeHTTP.fakeHTTP()
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")!
        apiClient.http = fakeHTTP
        let amexClient = BTAmericanExpressClient(apiClient: apiClient)

        let options = Dictionary<String, Any>()
        amexClient.getRewardsBalance(options) { (payload, error) in
            XCTAssertNil(payload)
            guard let error = error as? NSError else {return}
            XCTAssertEqual(error.domain, BTAmericanExpressErrorDomain)
            XCTAssertEqual(error.code, BTAmericanExpressErrorType.invalidParameters.rawValue)
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testGetRewardsBalance_returnsInvalidParametersErrorWhenCurrencyIsoCodeNotPresent() {
        let expectation = self.expectation(description: "Options Error")
        let fakeHTTP = FakeHTTP.fakeHTTP()
        let apiClient = BTAPIClient(authorization: "development_tokenization_key")!
        apiClient.http = fakeHTTP
        let amexClient = BTAmericanExpressClient(apiClient: apiClient)

        let options = ["nonce": "face-nonce"]
        amexClient.getRewardsBalance(options) { (payload, error) in
            XCTAssertNil(payload)
            guard let error = error as? NSError else {return}
            XCTAssertEqual(error.domain, BTAmericanExpressErrorDomain)
            XCTAssertEqual(error.code, BTAmericanExpressErrorType.invalidParameters.rawValue)
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 10, handler: nil)
    }
}
