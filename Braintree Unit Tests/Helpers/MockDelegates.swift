import BraintreeCore
import XCTest

@objc class MockAppSwitchDelegate : NSObject, BTAppSwitchDelegate {
    var willPerformAppSwitch : XCTestExpectation? = nil
    var didPerformAppSwitch : XCTestExpectation? = nil
    var willProcess : XCTestExpectation? = nil
    var lastSender : AnyObject? = nil

    override init() { }

    init(willPerform: XCTestExpectation?, didPerform: XCTestExpectation?) {
        willPerformAppSwitch = willPerform
        didPerformAppSwitch = didPerform
    }

    @objc func braintreeWillPerformAppSwitch(sender: AnyObject!) {
        lastSender = sender
        willPerformAppSwitch?.fulfill()
    }

    @objc func braintree(sender: AnyObject!, didPerformAppSwitchToTarget target: BTAppSwitchTarget) {
        lastSender = sender
        didPerformAppSwitch?.fulfill()
    }

    @objc func braintreeWillProcessPaymentInfo(sender: AnyObject!) {
        lastSender = sender
        willProcess?.fulfill()
    }
}

@objc class MockViewControllerPresentationDelegate : NSObject, BTViewControllerPresentingDelegate {
    var requestsPresentationOfViewController : XCTestExpectation? = nil
    var requestsDismissalOfViewController : XCTestExpectation? = nil
    var lastViewController : UIViewController? = nil
    var lastSender : AnyObject? = nil

    @objc func braintree(sender: AnyObject!, requestsDismissalOfViewController viewController: UIViewController!) {
        lastSender = sender
        lastViewController = viewController
        requestsDismissalOfViewController?.fulfill()
    }

    @objc func braintree(sender: AnyObject!, requestsPresentationOfViewController viewController: UIViewController!) {
        lastSender = sender
        lastViewController = viewController
        requestsPresentationOfViewController?.fulfill()
    }
}
