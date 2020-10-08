import XCTest
import BraintreeTestShared

class BTTokenizationService_Venmo_Tests: XCTestCase {
    func testSingleton_hasVenmoTypeAvailable() {
        let sharedService = BTTokenizationService.shared()

        XCTAssertTrue(sharedService.isTypeAvailable("Venmo"))
    }

    //TODO: Fix this test since Demo app is not available
    func testSingleton_canAuthorizeVenmo() {
        let sharedService = BTTokenizationService.shared()
        //BTOCMockHelper().stubApplicationCanOpenURL()
        BTAppSwitch.setReturnURLScheme("com.braintreepayments.Demo.payments")
        let stubAPIClient = MockAPIClient(authorization: "development_fake_key")!
        stubAPIClient.cannedConfigurationResponseBody = BTJSON(value: [
            "payWithVenmo": [
                "environment": "sandbox",
                "merchantId": "stubmerchantid",
                "accessToken": "stubacesstoken"
            ],
        ])
        let mockDelegate = MockAppSwitchDelegate(willPerform: expectation(description: "Will authorize Venmo Account"), didPerform: nil)

        sharedService.tokenizeType("Venmo", options: [BTTokenizationServiceAppSwitchDelegateOption: mockDelegate], with: stubAPIClient) { _,_  -> Void in }

        waitForExpectations(timeout: 2, handler: nil)
    }
}
