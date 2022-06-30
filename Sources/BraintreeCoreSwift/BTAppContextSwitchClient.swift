import Foundation

@objc public protocol BTAppContextSwitchClientSwift {
    
    /// :nodoc: Determine whether the return URL can be handled.
    /// - Parameter returnURL: the URL you receive in  `scene(_:openURLContexts:)` (or `application(_:open:options:)` if not using SceneDelegate) when returning to your app
    /// - Returns: `true` when the SDK can process the return URL
    func canHandleReturnURL(_ url: URL) -> Bool
    
    ///  :nodoc: Complete payment flow after returning from app or browser switch.
    /// - Parameter url: The URL you receive in `scene(_:openURLContexts:)` (or `application(_:open:options:)` if not using SceneDelegate)
    func handleReturnURL(_ url: URL)
}
