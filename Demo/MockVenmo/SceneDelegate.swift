import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        AppSwitcher.openVenmoURL = URLContexts.first?.url
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        AppSwitcher.openVenmoURL = URL(string: "https://mobile-sdk-demo-site-838cead5d3ab.herokuapp.com/braintree-payments/braintreeAppSwitchVenmo")
    }
}
