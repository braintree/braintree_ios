import UIKit

/// Protocol for receiving payment lifecycle messages from a payment client that requires presentation of a view controller to authorize a payment.
@objc public protocol BTViewControllerPresentingDelegate: NSObjectProtocol {

    /// The payment client requires presentation of a view controller in order to proceed.
    ///
    /// Your implementation should present the viewController modally, e.g. via `presentViewController:animated:completion:`
    /// - Parameters:
    ///   - client: The payment client
    ///   - viewController: The view controller to present
    @objc(paymentClient:requestsPresentationOfViewController:)
    func paymentClient(_ client: Any, requestsPresentationOf viewController: UIViewController)

    ///  The payment client requires dismissal of a view controller.
    ///
    ///  Your implementation should dismiss the viewController, e.g. via `dismissViewControllerAnimated:completion:`
    /// - Parameters:
    ///   - client: The payment client
    ///   - viewController: The view controller to be dismissed
    @objc(paymentClient:requestsDismissalOfViewController:)
    func paymentClient(_ client: Any, requestsDismissalOf viewController: UIViewController)
}
