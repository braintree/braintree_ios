import XCTest
@testable import BraintreeCore

final class BTAPIClient_IntegrationTests: XCTestCase {

    func testFetchConfiguration_withTokenizationKey_returnsTheConfiguration() async throws {
        let apiClient = BTAPIClient(authorization: BTIntegrationTestsConstants.sandboxTokenizationKey)

        let configuration = try await apiClient.fetchOrReturnRemoteConfiguration()
        XCTAssertEqual(configuration.json?["merchantId"].asString(), "dcpspy2brwdjr3qn")
    }

    func testFetchConfiguration_withClientToken_returnsTheConfiguration() async throws {
        let apiClient = BTAPIClient(authorization: BTIntegrationTestsConstants.sandboxClientToken)

        let configuration = try await apiClient.fetchOrReturnRemoteConfiguration()
        // Note: client token uses a different merchant ID than the merchant whose tokenization key
        // we use in the other test
        XCTAssertEqual(configuration.json?["merchantId"].asString(), "348pk9cgf3bgyw2b")
    }

    func testFetchConfiguration_withVersionThreeClientToken_returnsTheConfiguration() async throws {
        let apiClient = BTAPIClient(authorization: BTIntegrationTestsConstants.sandboxClientTokenVersion3)

        let configuration = try await apiClient.fetchOrReturnRemoteConfiguration()
        // Note: client token uses a different merchant ID than the merchant whose tokenization key
        // we use in the other test
        XCTAssertEqual(configuration.json?["merchantId"].asString(), "dcpspy2brwdjr3qn")
    }
}
