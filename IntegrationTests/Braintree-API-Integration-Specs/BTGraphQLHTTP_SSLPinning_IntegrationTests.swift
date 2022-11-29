import Foundation
import XCTest
import BraintreeCore

class BTGraphQLHTTP_SSLPinning_IntegrationTests : XCTestCase {

    func testBTGraphQLHTTP_whenUsingProductionEnvironmentWithTrustedSSLCertificates_allowsNetworkCommunication_toBraintreeAPI() {
        let graphqlHttp = BTGraphQLHTTP(url: URL(string: "https://payments.braintree-api.com")!, tokenizationKey: "")

        let expectation = self.expectation(description: "Callback invoked")

        graphqlHttp.post("/ping") { body, response, error in
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testBTGraphQLHTTP_whenUsingSandboxEnvironmentWithTrustedSSLCertificates_allowsNetworkCommunication_toBraintreeAPI() {
        let graphqlHttp = BTGraphQLHTTP(url: URL(string: "https://payments.sandbox.braintree-api.com")!, tokenizationKey: "")

        let expectation = self.expectation(description: "Callback invoked")

        graphqlHttp.post("/ping") { body, response, error in
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

}
