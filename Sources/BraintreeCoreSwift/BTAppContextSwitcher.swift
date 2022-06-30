import UIKit

/// Handles return URLs when returning from app context switch and routes the return URL to the correct app context switch client class.
/// @note `returnURLScheme` must contain your app's registered URL Type that starts with the app's bundle ID.
/// When your app returns from app switch, the app delegate should call  `handleOpenURLContext:` (or `handleOpenURL` if not using SceneDelegate)
@objcMembers public class BTAppContextSwitcher: NSObject {
    
    public static let sharedInstance = BTAppContextSwitcher()
    
    /// The URL scheme to return to this app after switching to another app or opening a SFSafariViewController.
    /// This URL scheme must be registered as a URL Type in the app's info.plist, and it must start with the app's bundle ID.
    public var returnURLScheme: String = ""
    //TODO: Optimize this, it was a set in Objc
    private var appContextSwitchClients = [BTAppContextSwitchClient]()
    
    @objc(setReturnURLScheme:)
    public static func setReturnURL(scheme: String) {
        sharedInstance.returnURLScheme = scheme
    }
    
    @objc(handleOpenURL:)
    public static func handleOpen(_ url: URL) -> Bool {
        sharedInstance.handleOpen(url)
    }
    
    @objc(handleOpenURLContext:)
    public static func handleOpenURL(context: UIOpenURLContext) -> Bool {
        sharedInstance.handleOpen(context.url)
    }
    
    @objc(handleOpenURL:)
    public func handleOpen(_ url: URL) -> Bool {
        for appContextSwitchClient in appContextSwitchClients {
            if appContextSwitchClient.canHandleReturnURL(url) {
                return true
            }
        }
        return false
    }
    
    @objc(registerAppContextSwitchClient:)
    public func register(client: BTAppContextSwitchClient) {
        appContextSwitchClients.append(client)
    }
}
