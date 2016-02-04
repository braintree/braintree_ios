import XCTest

class BTPaymentButton_Tests: XCTestCase {

    var window : UIWindow!
    var viewController : UIViewController!

    override func setUp() {
        super.setUp()

        viewController = UIApplication.sharedApplication().windows[0].rootViewController
    }

    override func tearDown() {
        if viewController.presentedViewController != nil {
            viewController.dismissViewControllerAnimated(false, completion: nil)
        }

        super.tearDown()
    }

    func testPaymentButton_whenUsingTokenizationKey_doesNotCrash() {
        let apiClient = BTAPIClient(authorization: "development_testing_integration_merchant_id")!
        let paymentButton = BTPaymentButton(APIClient: apiClient) { _ in }
        let paymentButtonViewController = UIViewController()
        paymentButtonViewController.view.addSubview(paymentButton)

        viewController.presentViewController(paymentButtonViewController, animated: true, completion: nil)
    }

    func testPaymentButton_byDefault_hasAllPaymentOptions() {
        let stubAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        let paymentButton = BTPaymentButton(APIClient: stubAPIClient) { _ in }

        XCTAssertEqual(paymentButton.enabledPaymentOptions, NSOrderedSet(array: ["PayPal", "Venmo"]))
    }

    func testPaymentButton_whenPayPalIsEnabledInConfiguration_checksConfigurationForPaymentOptionAvailability() {
        let stubAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        let paymentButton = BTPaymentButton(APIClient: stubAPIClient) { _ in }
        paymentButton.configuration = BTConfiguration(JSON: BTJSON(value: [ "paypalEnabled": true ]))

        XCTAssertEqual(paymentButton.enabledPaymentOptions, NSOrderedSet(array: ["PayPal"]))
    }

    func testPaymentButton_whenVenmoIsEnabledInConfiguration_checksConfigurationForPaymentOptionAvailability() {
        let stubAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        let paymentButton = BTPaymentButton(APIClient: stubAPIClient) { _ in }
        let fakeApplication = FakeApplication()
        fakeApplication.cannedCanOpenURL = true
        paymentButton.application = fakeApplication
        paymentButton.configuration = BTConfiguration(JSON: BTJSON(value: [ "payWithVenmo": ["accessToken": "ACCESS_TOKEN"] ]))
        BTConfiguration.setBetaPaymentOption("venmo", isEnabled: true)

        XCTAssertEqual(paymentButton.enabledPaymentOptions, NSOrderedSet(array: ["Venmo"]))
    }

    func testPaymentButton_whenEnabledPaymentOptionsIsSetManually_skipsConfigurationValidation() {
        let stubAPIClient = MockAPIClient(authorization: "development_tokenization_key")!
        let paymentButton = BTPaymentButton(APIClient: stubAPIClient) { _ in }
        paymentButton.configuration = BTConfiguration(JSON: BTJSON(value: [ "paypalEnabled": false ]))

        paymentButton.enabledPaymentOptions = NSOrderedSet(array: ["PayPal"])
        XCTAssertEqual(paymentButton.enabledPaymentOptions, NSOrderedSet(array: ["PayPal"]))

        paymentButton.enabledPaymentOptions = NSOrderedSet(array: ["Venmo"])
        XCTAssertEqual(paymentButton.enabledPaymentOptions, NSOrderedSet(array: ["Venmo"]))
    }
    
}
