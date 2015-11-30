import XCTest

@objc class MockAppSwitchDelegate : NSObject, BTAppSwitchDelegate {
    var willPerformAppSwitchExpectation : XCTestExpectation? = nil
    var didPerformAppSwitchExpectation : XCTestExpectation? = nil
    var willProcessAppSwitchExpectation : XCTestExpectation? = nil
    // XCTestExpectations verify that delegates callbacks are made; the below bools verify that they are NOT made
    var willPerformAppSwitchCalled = false
    var didPerformAppSwitchCalled = false
    var willProcessAppSwitchCalled = false
    var lastAppSwitcher : AnyObject? = nil

    override init() { }

    init(willPerform: XCTestExpectation?, didPerform: XCTestExpectation?) {
        willPerformAppSwitchExpectation = willPerform
        didPerformAppSwitchExpectation = didPerform
    }

    @objc func appSwitcherWillPerformAppSwitch(appSwitcher: AnyObject) {
        lastAppSwitcher = appSwitcher
        willPerformAppSwitchExpectation?.fulfill()
        willPerformAppSwitchCalled = true
    }

    @objc func appSwitcher(appSwitcher: AnyObject, didPerformSwitchToTarget target: BTAppSwitchTarget) {
        lastAppSwitcher = appSwitcher
        didPerformAppSwitchExpectation?.fulfill()
        didPerformAppSwitchCalled = true
    }

    @objc func appSwitcherWillProcessPaymentInfo(appSwitcher: AnyObject) {
        lastAppSwitcher = appSwitcher
        willProcessAppSwitchExpectation?.fulfill()
        willProcessAppSwitchCalled = true
    }
}

@objc class MockViewControllerPresentationDelegate : NSObject, BTViewControllerPresentingDelegate {
    var requestsPresentationOfViewControllerExpectation : XCTestExpectation? = nil
    var requestsDismissalOfViewControllerExpectation : XCTestExpectation? = nil
    var lastViewController : UIViewController? = nil
    var lastPaymentDriver : AnyObject? = nil

    func paymentDriver(driver: AnyObject, requestsDismissalOfViewController viewController: UIViewController) {
        lastPaymentDriver = driver
        lastViewController = viewController
        requestsDismissalOfViewControllerExpectation?.fulfill()
    }

    func paymentDriver(driver: AnyObject, requestsPresentationOfViewController viewController: UIViewController) {
        lastPaymentDriver = driver
        lastViewController = viewController
        requestsPresentationOfViewControllerExpectation?.fulfill()
    }
}
