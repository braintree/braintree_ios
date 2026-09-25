import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        AppSwitcher.openVenmoURL = URLContexts.first?.url
        print("DEBUG - MockVenmo received openURLContexts: \(URLContexts.first?.url.absoluteString ?? "nil")")
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        AppSwitcher.openVenmoURL = URL(string: "https://mobile-sdk-demo-site-838cead5d3ab.herokuapp.com/braintree-payments/braintreeAppSwitchVenmo")
        let connectionURL = connectionOptions.urlContexts.first?.url.absoluteString ?? "nil"
        print("DEBUG - MockVenmo willConnectTo, connectionOptions.urlContexts: \(connectionURL)")
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        print("DEBUG - MockVenmo received continue userActivity webpageURL: \(userActivity.webpageURL?.absoluteString ?? "nil")")
    }
}
