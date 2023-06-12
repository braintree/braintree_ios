import Foundation

/// :nodoc: This protocol is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
@_documentation(visibility: private)
@objc public protocol BTAppContextSwitchClient: AnyObject {
    
    /// Determine whether the return URL can be handled.
    /// - Parameter url: the URL you receive in  `scene(_:openURLContexts:)` (or `application(_:open:options:)` if not using SceneDelegate) when returning to your app
    /// - Returns: `true` when the SDK can process the return URL
    static func canHandleReturnURL(_ url: URL) -> Bool
    
    /// Complete payment flow after returning from app or browser switch.
    /// - Parameter url: The URL you receive in `scene(_:openURLContexts:)` (or `application(_:open:options:)` if not using SceneDelegate)
    static func handleReturnURL(_ url: URL)
}
