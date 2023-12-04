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
        let request = BTPaymentInsightsRequest(
            email: "fake-email",
            phoneCountryCode: "fake-country-code",
            phoneNationalNumber: "fake-national-phone"
        )
        let result = try? await sut.getRecommendedPaymentMethods(request: request)
        
        XCTAssertNotNil(result!.isPayPalRecommended)
        XCTAssertNotNil(result!.isPayPalRecommended)
    }
}
