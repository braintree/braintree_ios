import Foundation
import XCTest
@testable import BraintreeCore
@testable import BraintreeTestShared

class BTPaymentInsightsClient_Tests: XCTestCase {
    
    var mockAPIClient = MockAPIClient(authorization: "development_client_key")!
    var sut: BTPaymentInsightsClient!
    
    override func setUp() {
        super.setUp()
        sut = BTPaymentInsightsClient(apiClient: mockAPIClient)
    }
    
    func testGetRecommendedPaymentMethods_returnsDefaultRecommendations() async {
        let result = try? await sut.getRecommendedPaymentMethods(email: "fake-email", phone: "fake-phone")
        
        XCTAssertNotNil(result!.isPayPalRecommended)
        XCTAssertNotNil(result!.isPayPalRecommended)
    }
}
