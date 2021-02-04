import XCTest
import BraintreeCore

@objc public class MockAppContextSwitchDelegate : NSObject, BTAppContextSwitchDelegate {

    public var appContextWillSwitchExpectation : XCTestExpectation? = nil
    public var appContextDidCompleteSwitchExpectation : XCTestExpectation? = nil
    public var appContextDidSwitchExpectation : XCTestExpectation? = nil

    // XCTestExpectations verify that delegates callbacks are made; the below bools verify that they are NOT made
    public var appContextDidSwitchCalled = false
    public var appContextWillSwitchCalled = false
    public var appContextDidCompleteSwitchCalled = false

    public var driver : BTAppContextSwitchDriver?

    public override init() { }

    @objc public func appContextSwitchDriverDidStartSwitch(_ driver: BTAppContextSwitchDriver) {
        self.driver = driver
        appContextDidSwitchExpectation?.fulfill()
        appContextDidSwitchCalled = true
    }

    @objc public func appContextSwitchDriverWillStartSwitch(_ driver: BTAppContextSwitchDriver) {
        self.driver = driver
        appContextWillSwitchExpectation?.fulfill()
        appContextWillSwitchCalled = true
    }

    @objc public func appContextSwitchDriverDidCompleteSwitch(_ driver: BTAppContextSwitchDriver) {
        self.driver = driver
        appContextDidCompleteSwitchExpectation?.fulfill()
        appContextDidCompleteSwitchCalled = true
    }

}

@objc public class MockViewControllerPresentationDelegate : NSObject, BTViewControllerPresentingDelegate {
    public var requestsPresentationOfViewControllerExpectation : XCTestExpectation? = nil
    public var requestsDismissalOfViewControllerExpectation : XCTestExpectation? = nil
    public var lastViewController : UIViewController? = nil
    public var lastPaymentDriver : AnyObject? = nil

    public func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
        lastPaymentDriver = driver as AnyObject?
        lastViewController = viewController
        requestsDismissalOfViewControllerExpectation?.fulfill()
    }

    public func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
        lastPaymentDriver = driver as AnyObject?
        lastViewController = viewController
        requestsPresentationOfViewControllerExpectation?.fulfill()
    }
}
