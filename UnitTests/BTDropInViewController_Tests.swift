import XCTest

class BTDropInViewController_Tests: XCTestCase {
    
    // MARK: - Metadata
    
    func testAPIClientMetadata_afterInstantiation_hasIntegrationSetToDropIn() {
        let apiClient = BTAPIClient(clientKey: "development_testing_integration_merchant_id")!
        let dropIn = BTDropInViewController(APIClient: apiClient)
        
        XCTAssertEqual(dropIn.apiClient.metadata.integration, BTClientMetadataIntegrationType.DropIn)
    }
    
    func testAPIClientMetadata_afterInstantiation_hasSourceSetToOriginalAPIClientMetadataSource() {
        var apiClient = BTAPIClient(clientKey: "development_testing_integration_merchant_id")!
        apiClient = apiClient.copyWithSource(BTClientMetadataSourceType.Unknown, integration: BTClientMetadataIntegrationType.Custom)
        let dropIn = BTDropInViewController(APIClient: apiClient)
        
        XCTAssertEqual(dropIn.apiClient.metadata.source, BTClientMetadataSourceType.Unknown)
    }
}
