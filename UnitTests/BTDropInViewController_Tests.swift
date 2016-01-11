import XCTest

class BTDropInViewController_Tests: XCTestCase {

    class BTDropInViewControllerTestDelegate : NSObject, BTDropInViewControllerDelegate {
        var didLoadExpectation: XCTestExpectation

        init(didLoadExpectation: XCTestExpectation) {
            self.didLoadExpectation = didLoadExpectation
        }

        @objc func dropInViewController(viewController: BTDropInViewController, didSucceedWithTokenization paymentMethodNonce: BTPaymentMethodNonce) {}

        @objc func dropInViewControllerDidCancel(viewController: BTDropInViewController) {}

        @objc func dropInViewControllerDidLoad(viewController: BTDropInViewController) {
            didLoadExpectation.fulfill()
        }
    }

    var window : UIWindow!
    var viewController : UIViewController!

    override func setUp() {
        super.setUp()

        window = UIWindow(frame: UIApplication.sharedApplication().windows[0].frame)
        viewController = UIViewController()
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }

    override func tearDown() {
        viewController.dismissViewControllerAnimated(false, completion: nil)
        window = nil
        UIApplication.sharedApplication().windows[0].makeKeyAndVisible()

        super.tearDown()
    }

    func testInitializesWithCheckoutRequestCorrectly() {
        let apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")!
        let request = BTPaymentRequest()
        let dropInViewController = BTDropInViewController(APIClient: apiClient)
        dropInViewController.paymentRequest = request
        XCTAssertEqual(request, dropInViewController.paymentRequest)
        XCTAssertEqual(apiClient.tokenizationKey, dropInViewController.apiClient.tokenizationKey)

        // By default, Drop-in does not set any bar button items. The developer should embed Drop-in in a navigation controller
        // as seen in BraintreeDemoDropInViewController, or provide some other way to dismiss Drop-in.
        XCTAssertNil(dropInViewController.navigationItem.leftBarButtonItem)
        XCTAssertNil(dropInViewController.navigationItem.rightBarButtonItem)

        let didLoadExpectation = self.expectationWithDescription("Drop-in did finish loading")
        let testDelegate = BTDropInViewControllerTestDelegate(didLoadExpectation: didLoadExpectation) // for strong reference
        dropInViewController.delegate = testDelegate

        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.viewController.presentViewController(dropInViewController, animated: false, completion: nil)
        }

        self.waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testInitializesWithoutCheckoutRequestCorrectly() {
        let apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")!
        let request = BTPaymentRequest()

        // When this is true, the call to action control will be hidden from Drop-in's content view. Instead, a submit button will be
        // added as a navigation bar button item. The default value is false.
        request.shouldHideCallToAction = true
        
        let dropInViewController = BTDropInViewController(APIClient: apiClient)
        dropInViewController.paymentRequest = request
        
        XCTAssertEqual(request, dropInViewController.paymentRequest)
        XCTAssertEqual(apiClient.tokenizationKey, dropInViewController.apiClient.tokenizationKey)
        XCTAssertNil(dropInViewController.navigationItem.leftBarButtonItem)

        // There will be a rightBarButtonItem instead of a call to action control because it has been set to hide.
        XCTAssertNotNil(dropInViewController.navigationItem.rightBarButtonItem)

        let didLoadExpectation = self.expectationWithDescription("Drop-in did finish loading")
        let testDelegate = BTDropInViewControllerTestDelegate(didLoadExpectation: didLoadExpectation) // for strong reference
        dropInViewController.delegate = testDelegate

        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.viewController.presentViewController(dropInViewController, animated: false, completion: nil)
        }
        self.waitForExpectationsWithTimeout(5, handler: nil)
    }

    func testDropIn_canSetNewCheckoutRequestAfterPresentation() {
        let apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")!
        let request = BTPaymentRequest()
        let dropInViewController = BTDropInViewController(APIClient: apiClient)
        dropInViewController.paymentRequest = request
        XCTAssertEqual(request, dropInViewController.paymentRequest)
        XCTAssertEqual(apiClient.tokenizationKey, dropInViewController.apiClient.tokenizationKey)

        // By default, Drop-in does not set any bar button items. The developer should embed Drop-in in a navigation controller
        // as seen in BraintreeDemoDropInViewController, or provide some other way to dismiss Drop-in.
        XCTAssertNil(dropInViewController.navigationItem.leftBarButtonItem)
        XCTAssertNil(dropInViewController.navigationItem.rightBarButtonItem)

        let didLoadExpectation = self.expectationWithDescription("Drop-in did finish loading")
        let testDelegate = BTDropInViewControllerTestDelegate(didLoadExpectation: didLoadExpectation) // for strong reference
        dropInViewController.delegate = testDelegate

        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.viewController.presentViewController(dropInViewController, animated: false, completion: nil)
        }
        self.waitForExpectationsWithTimeout(5, handler: nil)

        let newRequest = BTPaymentRequest()
        newRequest.shouldHideCallToAction = true
        dropInViewController.paymentRequest = newRequest
        XCTAssertNil(dropInViewController.navigationItem.leftBarButtonItem)

        // There will now be a rightBarButtonItem because shouldHideCallToAction = true; this button is the replacement
        // of the call to action control.
        XCTAssertNotNil(dropInViewController.navigationItem.rightBarButtonItem)
    }

    func testDropIn_addPaymentMethodViewController_hidesCTA() {
        let apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")!
        let dropInViewController = BTDropInViewController(APIClient: apiClient)
	        let addPaymentMethodDropInViewController = dropInViewController.addPaymentMethodDropInViewController()
        XCTAssertTrue(addPaymentMethodDropInViewController.paymentRequest!.shouldHideCallToAction)
        XCTAssertNotNil(addPaymentMethodDropInViewController.navigationItem.rightBarButtonItem)

        let didLoadExpectation = self.expectationWithDescription("Add payment method view controller did finish loading")
        let testDelegate = BTDropInViewControllerTestDelegate(didLoadExpectation: didLoadExpectation) // for strong reference
        addPaymentMethodDropInViewController.delegate = testDelegate

        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.viewController.presentViewController(addPaymentMethodDropInViewController, animated: false, completion: nil)
        }

        self.waitForExpectationsWithTimeout(5, handler: nil)
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
