import XCTest
import BraintreeCore

@objc public class MockViewControllerPresentingDelegate : NSObject, BTViewControllerPresentingDelegate {
    public var requestsPresentationOfViewControllerExpectation : XCTestExpectation? = nil
    public var requestsDismissalOfViewControllerExpectation : XCTestExpectation? = nil
    public var lastViewController : UIViewController? = nil
    public var lastPaymentClient : AnyObject? = nil

    public func paymentClient(_ client: Any, requestsDismissalOf viewController: UIViewController) {
        lastPaymentClient = client as AnyObject?
        lastViewController = viewController
        requestsDismissalOfViewControllerExpectation?.fulfill()
    }

    public func paymentClient(_ client: Any, requestsPresentationOf viewController: UIViewController) {
        lastPaymentClient = client as AnyObject?
        lastViewController = viewController
        requestsPresentationOfViewControllerExpectation?.fulfill()
    }
}
