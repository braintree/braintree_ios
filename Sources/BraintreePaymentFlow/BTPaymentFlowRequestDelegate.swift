import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// :nodoc: Protocol for payment flow processing.
@_documentation(visibility: private)
@objc public protocol BTPaymentFlowRequestDelegate {

    /// Handle payment request for a variety of web/app switch flows.
    ///
    /// Use the delegate to handle success/error/cancel flows.
    @objc func handle(_ request: BTPaymentFlowRequest, client apiClient: BTAPIClient, paymentClientDelegate delegate: BTPaymentFlowClientDelegate)
    
    /// Handles the return URL and completes and post processing.
    /// - Parameter url: The URL to check.
    @objc func handleOpen(_ url: URL)

    /// A short and unique alphanumeric name for the payment flow.
    ///
    /// Used for analytics/events. No spaces and all lowercase.
    @objc func paymentFlowName() -> String
}
