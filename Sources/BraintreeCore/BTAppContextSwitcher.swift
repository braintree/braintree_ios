import UIKit

/// Handles return URLs when returning from app context switch and routes the return URL to the correct app context switch client class.
/// - Note: `returnURLScheme` must contain your app's registered URL Type that starts with the app's bundle ID.
/// When your app returns from app switch, the app delegate should call  `handleOpenURL` (or `handleOpen` if not using SceneDelegate)
@objcMembers public class BTAppContextSwitcher: NSObject {
    
    // MARK: - Public Properties
    
    /// Singleton for shared instance of `BTAppContextSwitcher`
    public static let sharedInstance = BTAppContextSwitcher()
    
    /// The URL scheme to return to this app after switching to another app or opening a SFSafariViewController.
    /// This URL scheme must be registered as a URL Type in the app's info.plist, and it must start with the app's bundle ID.
    public var returnURLScheme: String = ""
    
    // MARK: - Private Properties
    
    private var appContextSwitchClients = [BTAppContextSwitchClient.Type]()
    
    // MARK: - Public Methods
    
    /// Determine whether the return URL can be handled.
    /// - Parameters: url the URL you receive in  `scene:openURLContexts:` (or `application:openURL:options:` if not using SceneDelegate) when returning to your app
    /// - Returns: `true` when the SDK can process the return URL
    @objc(handleOpenURLContext:)
    public func handleOpenURL(context: UIOpenURLContext) -> Bool {
        handleOpen(context.url)
    }
    
    /// Complete payment flow after returning from app or browser switch.
    /// - Parameter url:  The URL you receive in `scene:openURLContexts:` (or `application:openURL:options:` if not using SceneDelegate)
    /// - Returns: `true` when the SDK has handled the URL successfully
    @objc(handleOpenURL:)
    public func handleOpen(_ url: URL) -> Bool {
        for appContextSwitchClient in appContextSwitchClients {
            if appContextSwitchClient.canHandleReturnURL(url) {
                appContextSwitchClient.handleReturnURL(url)
                return true
            }
        }
        return false
    }
    
    /// Registers a class `Type` that can handle a return from app context switch with a static method.
    /// - Parameter client: A class `Type` that implements `BTAppContextSwitchClient`, the methods of which will be invoked statically on the class.
    @objc(registerAppContextSwitchClient:)
    public func register(_ client: BTAppContextSwitchClient.Type) {
        appContextSwitchClients.append(client)
    }
}
