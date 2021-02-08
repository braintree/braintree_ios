import XCTest
import BraintreeCore

@objc public class MockViewControllerPresentingDelegate : NSObject, BTViewControllerPresentingDelegate {
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
