import XCTest

@objc class MockPaymentDriverDelegate : NSObject, BTPaymentDriverDelegate {
    var willPerformAppSwitch : XCTestExpectation? = nil
    var didPerformAppSwitch : XCTestExpectation? = nil
    var willProcess : XCTestExpectation? = nil
    var requestsPresentationOfViewController : XCTestExpectation? = nil
    var requestsDismissalOfViewController : XCTestExpectation? = nil
    var lastViewController : UIViewController? = nil
    var lastPaymentDriver : AnyObject? = nil

    override init() { }

    init(willPerform: XCTestExpectation?, didPerform: XCTestExpectation?) {
        willPerformAppSwitch = willPerform
        didPerformAppSwitch = didPerform
    }

    @objc func paymentDriverWillPerformAppSwitch(driver: AnyObject!) {
        lastPaymentDriver = driver
        willPerformAppSwitch?.fulfill()
    }

    @objc func paymentDriver(driver: AnyObject!, didPerformAppSwitchToTarget target: BTAppSwitchTarget) {
        lastPaymentDriver = driver
        didPerformAppSwitch?.fulfill()
    }

    @objc func paymentDriverWillProcessPaymentInfo(driver: AnyObject!) {
        lastPaymentDriver = driver
        willProcess?.fulfill()
    }

    @objc func paymentDriver(driver: AnyObject!, requestsDismissalOfViewController viewController: UIViewController!) {
        lastPaymentDriver = driver
        lastViewController = viewController
        requestsDismissalOfViewController?.fulfill()
    }

    @objc func paymentDriver(driver: AnyObject!, requestsPresentationOfViewController viewController: UIViewController!) {
        lastPaymentDriver = driver
        lastViewController = viewController
        requestsPresentationOfViewController?.fulfill()
    }
}