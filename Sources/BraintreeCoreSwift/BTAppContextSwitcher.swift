import UIKit

/// Handles return URLs when returning from app context switch and routes the return URL to the correct app context switch client class.
/// - Note: `returnURLScheme` must contain your app's registered URL Type that starts with the app's bundle ID.
/// When your app returns from app switch, the app delegate should call  `handleOpenURL` (or `handleOpen` if not using SceneDelegate)
@objcMembers public class BTAppContextSwitcher: NSObject {
    
    /// Singleton for shared instance of `BTAppContextSwitcher`
    public static let sharedInstance = BTAppContextSwitcher()
    
    /// The URL scheme to return to this app after switching to another app or opening a SFSafariViewController.
    /// This URL scheme must be registered as a URL Type in the app's info.plist, and it must start with the app's bundle ID.
    public var returnURLScheme: String = ""
    private var appContextSwitchClients = [BTAppContextSwitchClient.Type]()
    
    @objc(handleOpenURLContext:)
    public func handleOpenURL(context: UIOpenURLContext) -> Bool {
        handleOpen(context.url)
    }
    
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
    
    @objc(registerAppContextSwitchClient:)
    public func register(_ client: BTAppContextSwitchClient.Type) {
        appContextSwitchClients.append(client)
    }
}
