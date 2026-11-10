import UIKit

/// :nodoc: This protocol is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
///
/// Used to mock `UIApplication`'s background task assertion API so that unit tests do not request
/// real task assertions from the system.
@_documentation(visibility: private)
public protocol BackgroundTaskManaging {
    func beginBackgroundTask(named: String?, expirationHandler handler: (() -> Void)?) -> UIBackgroundTaskIdentifier
    func endBackgroundTask(_ identifier: UIBackgroundTaskIdentifier)
}

// MARK: - BackgroundTaskManaging
extension UIApplication: BackgroundTaskManaging {

    /// :nodoc: This method is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    ///
    /// Adapts `beginBackgroundTask(withName:expirationHandler:)` to `BackgroundTaskManaging`. The adapter exists so the
    /// protocol requirement can use a plain `(() -> Void)?` handler rather than UIKit's `(@MainActor @Sendable () -> Void)?`,
    /// which would otherwise have to be matched exactly by every conforming test double.
    @_documentation(visibility: private)
    public func beginBackgroundTask(named: String?, expirationHandler handler: (() -> Void)?) -> UIBackgroundTaskIdentifier {
        beginBackgroundTask(withName: named, expirationHandler: handler)
    }
}
