import Foundation
import XCTest
@testable import BraintreeCore

final class BTGraphQLHTTP_SSLPinning_IntegrationTests: XCTestCase {

    func testBTGraphQLHTTP_whenUsingProductionEnvironmentWithTrustedSSLCertificates_allowsNetworkCommunication_toBraintreeAPI() async throws {
        let url = URL(string: "https://payments.braintree-api.com")!
        let graphqlHttp = BTGraphQLHTTP(authorization: try TokenizationKey("production_testing_merchant-id"), customBaseURL: url)
        _ = try await graphqlHttp.post("/ping")
    }

    func testBTGraphQLHTTP_whenUsingSandboxEnvironmentWithTrustedSSLCertificates_allowsNetworkCommunication_toBraintreeAPI() async throws {
        let url = URL(string: "https://payments.sandbox.braintree-api.com")!
        let graphqlHttp = BTGraphQLHTTP(authorization: try TokenizationKey("sandbox_testing_merchant-id"), customBaseURL: url)
        _ = try await graphqlHttp.post("/ping")
    }
}

