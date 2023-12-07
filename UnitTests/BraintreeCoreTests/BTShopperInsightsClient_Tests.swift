import Foundation
import XCTest
@testable import BraintreeCore
@testable import BraintreeTestShared

class BTShopperInsightsClient_Tests: XCTestCase {
    
    var mockAPIClient = MockAPIClient(authorization: "development_client_key")!
    var sut: BTShopperInsightsClient!
    
    override func setUp() {
        super.setUp()
        sut = BTShopperInsightsClient(apiClient: mockAPIClient)
    }
    
    func testGetRecommendedPaymentMethods_returnsDefaultRecommendations() async {
        let request = BTShopperInsightsRequest(
            email: "my-email",
            phone: BTShopperInsightsRequest.Phone(
                phoneCountryCode: "1",
                phoneNationalNumber: "1234567"
            )
        )
        let result = try? await sut.getRecommendedPaymentMethods(request: request)
        
        XCTAssertNotNil(result!.isPayPalRecommended)
        XCTAssertNotNil(result!.isVenmoRecommended)
    }
}
