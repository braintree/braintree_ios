import XCTest

class BTAPIClient_SwiftTests: XCTestCase {
    
    // MARK: - Initialization
    
    func testAPIClientInitialization_withValidTokenizationKey_returnsClientWithTokenizationKey() {
        let apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")!
        XCTAssertEqual(apiClient.tokenizationKey, "development_testing_integration_merchant_id")
    }
    
    func testAPIClientInitialization_withInvalidTokenizationKey_returnsNil() {
        XCTAssertNil(BTAPIClient(authorization: "invalid"))
    }
    
    func testAPIClientInitialization_withEmptyTokenizationKey_returnsNil() {
        XCTAssertNil(BTAPIClient(authorization: ""))
    }
    
    func testAPIClientInitialization_withValidClientToken_returnsClientWithClientToken() {
        let clientToken = BTTestClientTokenFactory.tokenWithVersion(2)
        let apiClient = BTAPIClient(authorization: clientToken)
        XCTAssertEqual(apiClient?.clientToken?.originalValue, clientToken)
    }
    
    // MARK: - Copy

    func testCopyWithSource_whenUsingClientToken_usesSameClientToken() {
        let clientToken = BTTestClientTokenFactory.tokenWithVersion(2)
        let apiClient = BTAPIClient(authorization: clientToken)

        let copiedApiClient = apiClient?.copyWithSource(.Unknown, integration: .Unknown)

        XCTAssertEqual(copiedApiClient?.clientToken?.originalValue, clientToken)
    }

    func testCopyWithSource_whenUsingTokenizationKey_usesSameTokenizationKey() {
        let apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")
        let copiedApiClient = apiClient?.copyWithSource(.Unknown, integration: .Unknown)
        XCTAssertEqual(copiedApiClient?.tokenizationKey, "development_testing_integration_merchant_id")
    }

    func testCopyWithSource_setsMetadataSourceAndIntegration() {
        let apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")
        let copiedApiClient = apiClient?.copyWithSource(.PayPalBrowser, integration: .DropIn)
        XCTAssertEqual(copiedApiClient?.metadata.source, .PayPalBrowser)
        XCTAssertEqual(copiedApiClient?.metadata.integration, .DropIn)
    }

    func testCopyWithSource_copiesHTTP() {
        let apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")
        let copiedApiClient = apiClient?.copyWithSource(.PayPalBrowser, integration: .DropIn)
        XCTAssertTrue(copiedApiClient !== apiClient)
    }

    // MARK: - Analytics
    
    func testAnalyticsService_byDefault_isASingleton() {
        let firstAPIClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")!
        let secondAPIClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")!
        XCTAssertTrue(firstAPIClient.analyticsService === secondAPIClient.analyticsService)
    }

}
