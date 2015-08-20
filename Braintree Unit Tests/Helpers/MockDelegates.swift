import BraintreeCore
import XCTest

@objc class MockAppSwitchDelegate : NSObject, BTAppSwitchDelegate {
    var willPerformAppSwitch : XCTestExpectation? = nil
    var didPerformAppSwitch : XCTestExpectation? = nil
    var willProcess : XCTestExpectation? = nil
    var lastAppSwitcher : AnyObject? = nil

    override init() { }

    init(willPerform: XCTestExpectation?, didPerform: XCTestExpectation?) {
        willPerformAppSwitch = willPerform
        didPerformAppSwitch = didPerform
    }

    @objc func appSwitcherWillPerformAppSwitch(appSwitcher: AnyObject!) {
        lastAppSwitcher = appSwitcher
        willPerformAppSwitch?.fulfill()
    }

    @objc func appSwitcher(appSwitcher: AnyObject!, didPerformSwitchToTarget target: BTAppSwitchTarget) {
        lastAppSwitcher = appSwitcher
        didPerformAppSwitch?.fulfill()
    }

    @objc func appSwitcherWillProcessPaymentInfo(appSwitcher: AnyObject!) {
        lastAppSwitcher = appSwitcher
        willProcess?.fulfill()
    }
}

@objc class MockViewControllerPresentationDelegate : NSObject, BTViewControllerPresentingDelegate {
    var requestsPresentationOfViewController : XCTestExpectation? = nil
    var requestsDismissalOfViewController : XCTestExpectation? = nil
    var lastViewController : UIViewController? = nil
    var lastPaymentDriver : AnyObject? = nil

    func paymentDriver(driver: AnyObject!, requestsDismissalOfViewController viewController: UIViewController!) {
        lastPaymentDriver = driver
        lastViewController = viewController
        requestsDismissalOfViewController?.fulfill()
    }

    func paymentDriver(driver: AnyObject!, requestsPresentationOfViewController viewController: UIViewController!) {
        lastPaymentDriver = driver
        lastViewController = viewController
        requestsPresentationOfViewController?.fulfill()
    }
}
