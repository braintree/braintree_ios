import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// :nodoc: Protocol for payment flow processing via BTPaymentFlowRequestDelegate.
@_documentation(visibility: private)
@objc public protocol BTPaymentFlowClientDelegate {
    
    /// Use when payment URL is ready for processing.
    @objc func onPayment(with url: URL?, error: Error?)

    /// Use when the payment flow has completed or encountered an error.
    /// - Parameters:
    ///   - result: The BTPaymentFlowResult of the payment flow.
    ///   - error: NSError containing details of the error.
    @objc func onPaymentComplete(_ result: BTPaymentFlowResult?, error: Error?)
    
    /// Returns the BTAPIClient used by the BTPaymentFlowClientDelegate.
    /// - Returns: The BTAPIClient used by the client.
    @objc func apiClient() -> BTAPIClient
}
