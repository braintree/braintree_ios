import XCTest
@testable import BraintreeCore

final class BTHTTP_SSLPinning_IntegrationTests: XCTestCase {

    func testBTHTTP_whenUsingProductionEnvironmentWithTrustedSSLCertificates_allowsNetworkCommunication() {
        let url = URL(string: "https://api.braintreegateway.com")!
        let http = BTHTTP(url: url, tokenizationKey: "development_testing_integration_merchant_id")
        let expectation = expectation(description: "Callback invoked")

        http.get("/heartbeat.json") { body, _, error in
            XCTAssertNil(error)
            XCTAssertEqual(body?["heartbeat"].asString(), "d2765eaa0dad9b300b971f074-production")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testBTHTTP_whenUsingSandboxEnvironmentWithTrustedSSLCertificates_allowsNetworkCommunication() {
        let url = URL(string: "https://api.sandbox.braintreegateway.com")!
        let http = BTHTTP(url: url, tokenizationKey: "development_testing_integration_merchant_id")
        let expectation = expectation(description: "Callback invoked")

        http.get("/heartbeat.json") { body, _, error in
            XCTAssertNil(error)
            XCTAssertEqual(body?["heartbeat"].asString(), "d2765eaa0dad9b300b971f074-sandbox")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testBTHTTP_whenUsingAServerWithValidCertificateChainWithARootCAThatWeDoNotExplicitlyTrust_doesNotAllowNetworkCommunication() {
        let url = URL(string: "https://www.globalsign.com")!
        let http = BTHTTP(url: url, tokenizationKey: "development_testing_integration_merchant_id")
        let expectation = expectation(description: "Callback invoked")

        http.get("/heartbeat.json") { body, response, error in
            XCTAssertNil(body)
            XCTAssertNil(response)

            let error = error as NSError?
            XCTAssertEqual(error?.domain, URLError.errorDomain)
            XCTAssertEqual(error?.code, URLError.serverCertificateUntrusted.rawValue)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }
     
    func testHTTP_whenUsingProductionEnvironmentWithTrustedSSLCertificates_allowsNetworkCommunication_toBraintreeAPI() {
        let http = BTHTTP(url: URL(string: "https://api.braintreegateway.com")!, tokenizationKey: "")

        let expectation = self.expectation(description: "Callback invoked")

        http.get("") { body, response, error in
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testHTTP_whenUsingSandboxEnvironmentWithTrustedSSLCertificates_allowsNetworkCommunication_toBraintreeAPI() {
        let http = BTHTTP(url: URL(string: "https://api.sandbox.braintreegateway.com")!, tokenizationKey: "")

        let expectation = self.expectation(description: "Callback invoked")

        http.get("") { body, response, error in
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testHTTP_whenUsingQAEnvironmentWithTrustedSSLCertificates_allowsNetworkCommunication_toBraintreeAPI() {
        let http = BTHTTP(url: URL(string: "https://gateway.qa.braintreepayments.com")!, tokenizationKey: "")

        let expectation = self.expectation(description: "Callback invoked")

        http.get("") { body, response, error in
            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
}
