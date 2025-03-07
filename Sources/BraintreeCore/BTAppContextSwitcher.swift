import UIKit

/// Handles return URLs when returning from app context switch and routes the return URL to the correct app context switch client class.
/// - Note: `returnURLScheme` must contain your app's registered URL Type that starts with the app's bundle ID.
/// When your app returns from app switch, the app delegate should call  `handleOpenURL` (or `handleOpen` if not using SceneDelegate)
@_documentation(visibility: private)
public class BTAppContextSwitcher: NSObject {
    
    // MARK: - Public Properties
    
    /// Singleton for shared instance of `BTAppContextSwitcher`
    public static let sharedInstance = BTAppContextSwitcher()

    // MARK: - Private Properties
    
    private var appContextSwitchClients: [BTAppContextSwitchClient.Type] = []

    // MARK: - Public Methods
    
    /// Determine whether the return URL can be handled.
    /// - Parameters: url the URL you receive in  `scene:openURLContexts:` (or `application:openURL:options:` if not using SceneDelegate) when returning to your app
    /// - Returns: `true` when the SDK can process the return URL
    @discardableResult public func handleOpenURL(context: UIOpenURLContext) -> Bool {
        handleOpen(context.url)
    }
    
    /// Complete payment flow after returning from app or browser switch.
    /// - Parameter url:  The URL you receive in `scene:openURLContexts:` (or `application:openURL:options:` if not using SceneDelegate)
    /// - Returns: `true` when the SDK has handled the URL successfully
    @discardableResult public func handleOpen(_ url: URL) -> Bool {
        for appContextSwitchClient in appContextSwitchClients where appContextSwitchClient.canHandleReturnURL(url) {
            appContextSwitchClient.handleReturnURL(url)
            return true
        }
        return false
    }
    
    /// Registers a class `Type` that can handle a return from app context switch with a static method.
    /// - Parameter client: A class `Type` that implements `BTAppContextSwitchClient`, the methods of which will be invoked statically on the class.
    public func register(_ client: BTAppContextSwitchClient.Type) {
        appContextSwitchClients.append(client)
    }
}
