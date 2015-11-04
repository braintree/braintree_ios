import XCTest

class BTDropInViewController_Tests: XCTestCase {
    
    func testInitializesWithCheckoutRequestCorrectly() {
        let apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")!
        let request = BTPaymentRequest()
        let dropIn = BTDropInViewController(APIClient: apiClient)
        dropIn.paymentRequest = request
        XCTAssertEqual(request, dropIn.paymentRequest)
        XCTAssertEqual(apiClient.tokenizationKey, dropIn.apiClient.tokenizationKey) // Tokenization key should be the same
        XCTAssertNil(dropIn.navigationItem.rightBarButtonItem) // TODO: Will this be set when the view controller is presented (viewDidLoad)?
    }
    
    func testInitializesWithoutCheckoutRequestCorrectly() {
        let apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")!
        let request = BTPaymentRequest()
        request.shouldHideCallToAction = false // TODO: Investigate the rightBarButtonItem
        
        let dropIn = BTDropInViewController(APIClient: apiClient)
        dropIn.paymentRequest = request
        
        XCTAssertEqual(request, dropIn.paymentRequest)
        XCTAssertEqual(apiClient.tokenizationKey, dropIn.apiClient.tokenizationKey) // Tokenization key should be the same
        XCTAssertNil(dropIn.navigationItem.rightBarButtonItem)
    }

    func pendInitializesWithCheckoutRequestAndSetsNewCheckoutRequest() {
        
        // TODO
        
        let apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")!
        let request = BTPaymentRequest()
        let dropIn = BTDropInViewController(APIClient: apiClient)
        XCTAssertEqual(request, dropIn.paymentRequest)
        XCTAssertEqual(apiClient.tokenizationKey, dropIn.apiClient.tokenizationKey) // Tokenization key should be the same
        XCTAssertNil(dropIn.navigationItem.rightBarButtonItem) // This will be set when the view controller is presented (viewDidLoad)
    }
    
    // MARK: - Metadata
    
    func testAPIClientMetadata_afterInstantiation_hasIntegrationSetToDropIn() {
        let apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")!
        let dropIn = BTDropInViewController(APIClient: apiClient)
        
        XCTAssertEqual(dropIn.apiClient.metadata.integration, BTClientMetadataIntegrationType.DropIn)
    }
    
    func testAPIClientMetadata_afterInstantiation_hasSourceSetToOriginalAPIClientMetadataSource() {
        var apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")!
        apiClient = apiClient.copyWithSource(BTClientMetadataSourceType.Unknown, integration: BTClientMetadataIntegrationType.Custom)
        let dropIn = BTDropInViewController(APIClient: apiClient)
        
        XCTAssertEqual(dropIn.apiClient.metadata.source, BTClientMetadataSourceType.Unknown)
    }
}
