import XCTest
import BraintreePaymentFlow
import BraintreeTestShared
import SafariServices

class BTPaymentFlow_Tests: XCTestCase {

    var mockAPIClient : MockAPIClient!

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
    }

    func testInformDelegatePresentingViewControllerRequestPresent_setsVCDismissButtonStyleToCancel() {
        let paymentFlowClient = BTPaymentFlowClient(apiClient: mockAPIClient)
        let viewControllerPresentingDelegate = MockViewControllerPresentingDelegate()

        paymentFlowClient.viewControllerPresentingDelegate = viewControllerPresentingDelegate
        paymentFlowClient.informDelegatePresentingViewControllerRequestPresent(URL(string:"http://sample.com"))

        let buttonStyle = (viewControllerPresentingDelegate.lastViewController as! SFSafariViewController).dismissButtonStyle
        XCTAssertEqual(buttonStyle, .cancel)
    }

}
