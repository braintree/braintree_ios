import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        AppSwitcher.openVenmoURL = URLContexts.first?.url
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let urlContexts = connectionOptions.urlContexts
        AppSwitcher.openVenmoURL = urlContexts.first?.url
    }
}
