import UIKit
import BraintreeCore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        if let windowScene = scene as? UIWindowScene {
            window = UIWindow(windowScene: windowScene)
            window?.rootViewController = UINavigationController(rootViewController: ContainmentViewController())
            window?.makeKeyAndVisible()
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        URLContexts.forEach { urlContext in
            let url = urlContext.url
            if url.scheme?.localizedCaseInsensitiveCompare("com.braintreepayments.Demo.payments") == .orderedSame {
                _ = BTAppContextSwitcher.sharedInstance.handleOpenURL(context: urlContext)
            }
        }
    }
}
