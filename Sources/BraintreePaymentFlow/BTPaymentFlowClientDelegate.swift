/// :nodoc: Protocol for payment flow processing via BTPaymentFlowRequestDelegate.
public protocol BTPaymentFlowClientDelegate {
    
    /// :nodoc: Use when payment URL is ready for processing.
    func onPayment(with url: URL?, error: Error?)

    /// :nodoc: Use when the payment flow has completed or encountered an error.
    /// - Parameters:
    ///   - result: The BTPaymentFlowResult of the payment flow.
    ///   - error: NSError containing details of the error.
    func onPaymentComplete(_ result: BTPaymentFlowResult?, error: Error?)
    
    /// :nodoc: Returns the BTAPIClient used by the BTPaymentFlowClientDelegate.
    /// - Returns: The BTAPIClient used by the client.
    func apiClient() -> BTAPIClient
}
