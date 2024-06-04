import Foundation
import XCTest
@testable import BraintreeCore

class BTGraphQLHTTP_SSLPinning_IntegrationTests : XCTestCase {

    func testBTGraphQLHTTP_whenUsingProductionEnvironmentWithTrustedSSLCertificates_allowsNetworkCommunication_toBraintreeAPI() {
        let url = URL(string: "https://payments.braintree-api.com")!

        let expectation = self.expectation(description: "Callback invoked")
        
        let graphqlHttp = BTGraphQLHTTP(authorization: try! TokenizationKey("production_testing_merchant-id"), customBaseURL: url)
        graphqlHttp.post("/ping") { body, response, error in
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testBTGraphQLHTTP_whenUsingSandboxEnvironmentWithTrustedSSLCertificates_allowsNetworkCommunication_toBraintreeAPI() {
        let url = URL(string: "https://payments.sandbox.braintree-api.com")!
        
        let expectation = self.expectation(description: "Callback invoked")

        let graphqlHttp = BTGraphQLHTTP(authorization: try! TokenizationKey("sandbox_testing_merchant-id"), customBaseURL: url)
        graphqlHttp.post("/ping") { body, response, error in
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

}
