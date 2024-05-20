import Foundation
import XCTest
@testable import BraintreeCore

class BTGraphQLHTTP_SSLPinning_IntegrationTests : XCTestCase {

    func testBTGraphQLHTTP_whenUsingProductionEnvironmentWithTrustedSSLCertificates_allowsNetworkCommunication_toBraintreeAPI() {
        let json = BTJSON(value: [
            "clientApiUrl": "https://fake-client-api-url.com/path",
            "graphQL": [
                "url": "https://payments.braintree-api.com"
            ]
        ])
        let prodConfiguration = BTConfiguration(json: json)

        let expectation = self.expectation(description: "Callback invoked")
        
        let graphqlHttp = BTGraphQLHTTP(authorization: try! TokenizationKey("production_testing_merchant-id"))
        graphqlHttp.post("/ping", configuration: prodConfiguration) { body, response, error in
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testBTGraphQLHTTP_whenUsingSandboxEnvironmentWithTrustedSSLCertificates_allowsNetworkCommunication_toBraintreeAPI() {
        let json = BTJSON(value: [
            "clientApiUrl": "https://fake-client-api-url.com/path",
            "graphQL": [
                "url": "https://payments.sandbox.braintree-api.com"
            ]
        ])
        let sandConfiguration = BTConfiguration(json: json)
        
        let expectation = self.expectation(description: "Callback invoked")

        let graphqlHttp = BTGraphQLHTTP(authorization: try! TokenizationKey("sandbox_testing_merchant-id"))
        graphqlHttp.post("/ping", configuration: sandConfiguration) { body, response, error in
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

}
