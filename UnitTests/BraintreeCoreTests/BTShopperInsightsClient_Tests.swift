import Foundation
import XCTest
@testable import BraintreeCore
@testable import BraintreeTestShared

class BTShopperInsightsClient_Tests: XCTestCase {
    
    var mockAPIClient = MockAPIClient(authorization: "development_client_key")!
    var sut: BTShopperInsightsClient!
    var fakeApplication: FakeApplication!
    
    override func setUp() {
        super.setUp()
        sut = BTShopperInsightsClient(apiClient: mockAPIClient)
        fakeApplication = FakeApplication()
        sut.application = fakeApplication
    }
    
    func testGetRecommendedPaymentMethods_returnsDefaultRecommendations() async {
        let request = BTShopperInsightsRequest(
            email: "fake-email",
            phoneCountryCode: "fake-country-code",
            phoneNationalNumber: "fake-national-phone"
        )
        let result = try? await sut.getRecommendedPaymentMethods(request: request)
        
        XCTAssertNotNil(result!.isPayPalRecommended)
        XCTAssertNotNil(result!.isVenmoRecommended)
    }
    
    func testGetRecommendedPaymentMethods_whenVenmoInstalled_returnsRecommendation() async {
        fakeApplication.canOpenURLWhitelist.append(URL(string: "com.venmo.touch.v2://x-callback-url/path")!)
        
        let request = BTShopperInsightsRequest(
            email: "fake-email",
            phoneCountryCode: "fake-country-code",
            phoneNationalNumber: "fake-national-phone"
        )
        let result = try? await sut.getRecommendedPaymentMethods(request: request)
        
        XCTAssertTrue(result!.isVenmoRecommended)
    }
    
    func testGetRecommendedPaymentMethods_whenPayPalInstalled_returnsRecommendation() async {
        fakeApplication.canOpenURLWhitelist.append(URL(string: "paypal://x-callback-url/path")!)
        
        let request = BTShopperInsightsRequest(
            email: "fake-email",
            phoneCountryCode: "fake-country-code",
            phoneNationalNumber: "fake-national-phone"
        )
        let result = try? await sut.getRecommendedPaymentMethods(request: request)
        
        XCTAssertTrue(result!.isPayPalRecommended)
    }
}
