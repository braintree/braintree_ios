import Foundation

@objc public protocol BTLocalPaymentRequestDelegate {
         
    /// Required delegate method which returns the payment ID before the flow starts.
    ///
    /// Use this to do any preprocessing and setup for webhooks. Use the `start()` callback to continue the flow.
    @objc func localPaymentStarted(_ request: BTLocalPaymentRequest, paymentID: String, start: @escaping () -> Void)
}
