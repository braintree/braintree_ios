import UIKit

/// Handles return URLs when returning from app context switch and routes the return URL to the correct app context switch client class.
/// - Note: `returnURLScheme` must contain your app's registered URL Type that starts with the app's bundle ID.
/// When your app returns from app switch, the app delegate should call  `handleOpenURL` (or `handleOpen` if not using SceneDelegate)
@objcMembers public class BTAppContextSwitcher: NSObject {
    
    // MARK: - Public Properties
    
    /// Singleton for shared instance of `BTAppContextSwitcher`
    public static let sharedInstance = BTAppContextSwitcher()
   
    // NEXT_MAJOR_VERSION: move this property into the feature client request where it is used
    /// The URL scheme to return to this app after switching to another app or opening a SFSafariViewController.
    /// This URL scheme must be registered as a URL Type in the app's info.plist, and it must start with the app's bundle ID.
    /// - Note: This property should only be used for the Venmo flow.
    @available(
        *,
        deprecated,
        message: "returnURLScheme is deprecated and will be removed in a future version. Use BTVenmoClient(apiClient:universalLink:)."
    )
    public var returnURLScheme: String {
        get { _returnURLScheme }
        set { _returnURLScheme = newValue }
    }

    // swiftlint:disable identifier_name
    /// :nodoc: This method is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    /// Property for `returnURLScheme`. Created to avoid deprecation warnings upon accessing
    /// `returnURLScheme` directly within our SDK. Use this value instead.
    public var _returnURLScheme: String = ""
    // swiftlint:enable identifier_name

    // MARK: - Private Properties
    
    private var appContextSwitchClients: [BTAppContextSwitchClient.Type] = []

    // MARK: - Public Methods
    
    /// Determine whether the return URL can be handled.
    /// - Parameters: url the URL you receive in  `scene:openURLContexts:` (or `application:openURL:options:` if not using SceneDelegate) when returning to your app
    /// - Returns: `true` when the SDK can process the return URL
    @objc(handleOpenURLContext:)
    @discardableResult public func handleOpenURL(context: UIOpenURLContext) -> Bool {
        handleOpen(context.url)
    }
    
    /// Complete payment flow after returning from app or browser switch.
    /// - Parameter url:  The URL you receive in `scene:openURLContexts:` (or `application:openURL:options:` if not using SceneDelegate)
    /// - Returns: `true` when the SDK has handled the URL successfully
    @objc(handleOpenURL:)
    @discardableResult public func handleOpen(_ url: URL) -> Bool {
        for appContextSwitchClient in appContextSwitchClients where appContextSwitchClient.canHandleReturnURL(url) {
            appContextSwitchClient.handleReturnURL(url)
            return true
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
