import XCTest

class BTPaymentButton_Tests: XCTestCase {
    
    func testPaymentButton_whenUsingTokenizationKey_doesNotCrash() {
        let apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")!
        let paymentButton = BTPaymentButton(APIClient: apiClient) { _ in }
        let viewController = UIViewController()
        viewController.view.addSubview(paymentButton)
        let window = UIWindow()
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
    
}
