import XCTest
@testable import BraintreeCore

final class BTHTTP_SSLPinning_IntegrationTests: XCTestCase {

    func testBTHTTP_whenUsingProductionEnvironmentWithTrustedSSLCertificates_allowsNetworkCommunication() async throws {
        let url = URL(string: "https://api.braintreegateway.com")!
        let http = BTHTTP(authorization: try TokenizationKey("development_testing_integration_merchant_id"), customBaseURL: url)
        let (body, _) = try await http.get("/heartbeat.json")
        XCTAssertEqual(body["heartbeat"].asString(), "d2765eaa0dad9b300b971f074-production")
    }

    func testBTHTTP_whenUsingSandboxEnvironmentWithTrustedSSLCertificates_allowsNetworkCommunication() async throws {
        let url = URL(string: "https://api.sandbox.braintreegateway.com")!
        let http = BTHTTP(authorization: try TokenizationKey("sandbox_testing_integration_merchant_id"), customBaseURL: url)
        let (body, _) = try await http.get("/heartbeat.json")
        XCTAssertEqual(body["heartbeat"].asString(), "d2765eaa0dad9b300b971f074-sandbox")
    }

    func testBTHTTP_whenUsingAServerWithValidCertificateChainWithARootCAThatWeDoNotExplicitlyTrust_doesNotAllowNetworkCommunication() async {
        let url = URL(string: "https://www.globalsign.com")!
        let http = BTHTTP(authorization: try! TokenizationKey("development_testing_integration_merchant_id"), customBaseURL: url)

        do {
            _ = try await http.get("/heartbeat.json")
            XCTFail("Expected SSL error to be thrown")
        } catch let error as NSError {
            XCTAssertEqual(error.domain, URLError.errorDomain)
            XCTAssertEqual(error.code, URLError.serverCertificateUntrusted.rawValue)
        }
    }
}
