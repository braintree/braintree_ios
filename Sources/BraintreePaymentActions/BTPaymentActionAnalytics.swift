import Foundation

enum BTPaymentActionAnalytics {

    // MARK: - Set Payment Action Payment Method Events

    static let setPaymentActionPaymentMethodStarted = "payment-actions:set-payment-action-payment-method:started"
    static let setPaymentActionPaymentMethodSucceeded = "payment-actions:set-payment-action-payment-method:succeeded"
    static let setPaymentActionPaymentMethodFailed = "payment-actions:set-payment-action-payment-method:failed"

    // MARK: - 3D Secure Lifecycle Events

    static let verifyStarted = "payment-actions:verify:started"
    /// The SDK completed the 3DS flow without an error. This is not an authentication or payment result:
    /// a Cardinal-reported challenge failure still ends here, since the server makes the final call.
    static let verifySucceeded = "payment-actions:verify:succeeded"
    static let verifyFailed = "payment-actions:verify:failed"
    static let verifyCanceled = "payment-actions:verify:canceled"

    // MARK: - Device Data Collection Events

    static let deviceDataCollectionStarted = "payment-actions:ddc:started"
    static let deviceDataCollectionSucceeded = "payment-actions:ddc:succeeded"
    static let deviceDataCollectionFailed = "payment-actions:ddc:failed"

    // MARK: - 3D Secure Challenge Events

    static let challengeSucceeded = "payment-actions:verify:challenge:succeeded"
    static let challengeFailed = "payment-actions:verify:challenge:failed"
}
