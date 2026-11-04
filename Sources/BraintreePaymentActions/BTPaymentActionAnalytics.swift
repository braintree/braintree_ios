import Foundation

enum BTPaymentActionAnalytics {

    // MARK: - Set Payment Action Payment Method Events

    static let setPaymentActionPaymentMethodStarted = "payment-actions:set-payment-action-payment-method:started"
    static let setPaymentActionPaymentMethodSucceeded = "payment-actions:set-payment-action-payment-method:succeeded"
    static let setPaymentActionPaymentMethodFailed = "payment-actions:set-payment-action-payment-method:failed"

    // MARK: - 3D Secure Lifecycle Events

    static let verifyStarted = "payment-actions:3ds:verify:started"
    static let verifySucceeded = "payment-actions:3ds:verify:succeeded"
    static let verifyFailed = "payment-actions:3ds:verify:failed"
    static let verifyCanceled = "payment-actions:3ds:verify:canceled"

    // MARK: - 3D Secure Device Data Collection Events

    static let ddcStarted = "payment-actions:3ds:verify:ddc:started"
    static let ddcSucceeded = "payment-actions:3ds:verify:ddc:succeeded"
    static let ddcFailed = "payment-actions:3ds:verify:ddc:failed"

    // MARK: - 3D Secure Challenge Events

    static let challengePresented = "payment-actions:3ds:verify:challenge:presented"
    static let challengeSucceeded = "payment-actions:3ds:verify:challenge:succeeded"
    static let challengeFailed = "payment-actions:3ds:verify:challenge:failed"

    // MARK: - 3D Secure Signal Events

    static let signalSucceeded = "payment-actions:3ds:verify:signal:succeeded"
    static let signalFailed = "payment-actions:3ds:verify:signal:failed"

    // MARK: - 3D Secure Version Anomaly Event

    static let versionAnomaly = "payment-actions:3ds:verify:version-anomaly"
}
