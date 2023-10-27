import XCTest
@testable import BraintreeCore

final class BTAPIClient_IntegrationTests: XCTestCase {

    func testFetchConfiguration_withTokenizationKey_returnsTheConfiguration() {
        let apiClient = BTAPIClient(authorization: BTIntegrationTestsConstants.sandboxTokenizationKey)
        let expectation = expectation(description: "Fetch configuration")

        apiClient?.fetchOrReturnRemoteConfiguration { configuration, error in
            XCTAssertEqual(configuration?.json?["merchantId"].asString(), "dcpspy2brwdjr3qn")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10)
    }

    func testFetchConfiguration_withClientToken_returnsTheConfiguration() {
        let apiClient = BTAPIClient(authorization: BTIntegrationTestsConstants.sandboxClientToken)
        let expectation = expectation(description: "Fetch configuration")

        apiClient?.fetchOrReturnRemoteConfiguration { configuration, error in
            // Note: client token uses a different merchant ID than the merchant whose tokenization key
            // we use in the other test
            XCTAssertEqual(configuration?.json?["merchantId"].asString(), "348pk9cgf3bgyw2b")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testFetchConfiguration_withVersionThreeClientToken_returnsTheConfiguration() {
        let apiClient = BTAPIClient(authorization: BTIntegrationTestsConstants.sandboxClientTokenVersion3)
        let expectation = expectation(description: "Fetch configuration")

        apiClient?.fetchOrReturnRemoteConfiguration { configuration, error in
            // Note: client token uses a different merchant ID than the merchant whose tokenization key
            // we use in the other test
            XCTAssertEqual(configuration?.json?["merchantId"].asString(), "dcpspy2brwdjr3qn")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10)
    }
}
