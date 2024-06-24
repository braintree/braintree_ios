import UIKit
import BraintreeCore

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {
        
    private let returnURLScheme = "com.braintreepayments.Demo.payments"
    private let processInfoArgs = ProcessInfo.processInfo.arguments
    private let userDefaults = UserDefaults.standard
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        registerDefaultsFromSettings()
        persistDemoSettings()
        BTAppContextSwitcher.sharedInstance.returnURLScheme = returnURLScheme

        userDefaults.setValue(true, forKey: "magnes.debug.mode")
        
        return true
    }

    func registerDefaultsFromSettings() {
        if processInfoArgs.contains("-EnvironmentSandbox") {
            userDefaults.set(BraintreeDemoEnvironment.sandbox.rawValue, forKey: BraintreeDemoSettings.EnvironmentDefaultsKey)
        } else if processInfoArgs.contains("-EnvironmentProduction") {
            userDefaults.set(BraintreeDemoEnvironment.production.rawValue, forKey: BraintreeDemoSettings.EnvironmentDefaultsKey)
        }
        
        if processInfoArgs.contains("-ClientToken") {
            userDefaults.set(BraintreeDemoAuthType.clientToken.rawValue, forKey: BraintreeDemoSettings.AuthorizationTypeDefaultsKey)
        } else if processInfoArgs.contains("-TokenizationKey") {
            userDefaults.set(BraintreeDemoAuthType.tokenizationKey.rawValue, forKey: BraintreeDemoSettings.AuthorizationTypeDefaultsKey)
        } else if processInfoArgs.contains("-NewPayPalCheckoutTokenizationKey") {
            userDefaults.set(BraintreeDemoAuthType.newPayPalCheckoutTokenizationKey.rawValue, forKey: BraintreeDemoSettings.AuthorizationTypeDefaultsKey)
        } else if processInfoArgs.contains("-MockedPayPalTokenizationKey") {
            userDefaults.set(BraintreeDemoAuthType.mockedPayPalTokenizationKey.rawValue, forKey: BraintreeDemoSettings.AuthorizationTypeDefaultsKey)
        } else if processInfoArgs.contains("-UITestHardcodedClientToken") {
            userDefaults.set(BraintreeDemoAuthType.uiTestHardcodedClientToken.rawValue, forKey: BraintreeDemoSettings.AuthorizationTypeDefaultsKey)
        }
        
        userDefaults.removeObject(forKey: "BraintreeDemoSettingsAuthorizationOverride")
        processInfoArgs.forEach { arg in
            if arg.contains("-Integration:") {
                let testIntegration = arg.replacingOccurrences(of: "-Integration:", with: "")
                userDefaults.setValue(testIntegration, forKey: "BraintreeDemoSettingsIntegration")
            } else if arg.contains("-Authorization:") {
                let testIntegration = arg.replacingOccurrences(of: "-Authorization:", with: "")
                userDefaults.setValue(testIntegration, forKey: "BraintreeDemoSettingsAuthorizationOverride")
            }
        }
        
        if processInfoArgs.contains("-ClientTokenVersion2") {
            userDefaults.set("2", forKey: "BraintreeDemoSettingsClientTokenVersionDefaultsKey")
        } else if processInfoArgs.contains("-ClientTokenVersion3") {
            userDefaults.set("3", forKey: "BraintreeDemoSettingsClientTokenVersionDefaultsKey")
        }
    }
    
    func persistDemoSettings() {
        guard let settingsBundle = Bundle.main.path(forResource: "Settings", ofType: "bundle"),
              let settings = NSDictionary(contentsOfFile: settingsBundle.appending("/Root.plist")) else {
            print("Could not find Settings.bundle")
            return
        }
                
        if let preferences = settings.object(forKey: "PreferenceSpecifiers") as? Array<[String: Any]> {
            var defaultsToRegister: [String: Any] = [:]
            preferences.forEach { prefSpecification in
                if let key = prefSpecification["Key"] as? String, prefSpecification.keys.contains("DefaultValue") {
                    defaultsToRegister[key] = prefSpecification["DefaultValue"]
                }
            }
            
            userDefaults.register(defaults: defaultsToRegister)
        }
    }
    
    // MARK: - UISceneSession lifecycle
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
