public protocol BTLocalPaymentRequestDelegateSwift {
         
    /// Required delegate method which returns the payment ID before the flow starts.
    ///
    /// Use this to do any preprocessing and setup for webhooks. Use the `start()` callback to continue the flow.
    func localPaymentStarted(_ request: BTLocalPaymentRequest, paymentID: String, start: (() -> Void))
}
