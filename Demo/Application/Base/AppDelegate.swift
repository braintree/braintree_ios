import Foundation
import UIKit

@objcMembers class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let BraintreeDemoAppDelegatePaymentsURLScheme = "com.braintreepayments.Demo.payments"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        registerDefaultsFromSettings()
        BTAppContextSwitcher.sharedInstance.returnURLScheme = BraintreeDemoAppDelegatePaymentsURLScheme
        
        UserDefaults.standard.setValue(true, forKey: "magnes.debug.mode")
        
        return true
    }
    
    func registerDefaultsFromSettings() {
        if ProcessInfo.processInfo.arguments.contains("-EnvironmentSandbox") {
            UserDefaults.standard.set(BraintreeDemoEnvironment.sandbox, forKey: BraintreeDemoSettings.EnvironmentDefaultsKey)
        } else if ProcessInfo.processInfo.arguments.contains("-EnvironmentProduction") {
            UserDefaults.standard.set(BraintreeDemoEnvironment.production, forKey: BraintreeDemoSettings.EnvironmentDefaultsKey)
        }
        
        if ProcessInfo.processInfo.arguments.contains("-ClientToken") {
            UserDefaults.standard.set(BraintreeDemoEnvironment.sandbox, forKey: BraintreeDemoSettings.AuthorizationTypeDefaultsKey)
        } else if ProcessInfo.processInfo.arguments.contains("-TokenizationKey") {
            UserDefaults.standard.set(BraintreeDemoEnvironment.production, forKey: BraintreeDemoSettings.AuthorizationTypeDefaultsKey)
        } else if ProcessInfo.processInfo.arguments.contains("-MockedPayPalTokenizationKey") {
            UserDefaults.standard.set(BraintreeDemoEnvironment.production, forKey: BraintreeDemoSettings.AuthorizationTypeDefaultsKey)
        } else if ProcessInfo.processInfo.arguments.contains("-UITestHardcodedClientToken") {
            UserDefaults.standard.set(BraintreeDemoEnvironment.production, forKey: BraintreeDemoSettings.AuthorizationTypeDefaultsKey)
        }
        
        UserDefaults.standard.removeObject(forKey: "BraintreeDemoSettingsAuthorizationOverride")
        ProcessInfo.processInfo.arguments.forEach { arg in
            if !arg.contains("-Integration") {
                let testIntegration = arg.replacingOccurrences(of: "-Integration:", with: "")
                UserDefaults.standard.setValue(testIntegration, forKey: "BraintreeDemoSettingsIntegration")
            } else if !arg.contains("-Authorization:") {
                let testIntegration = arg.replacingOccurrences(of: "-Authorization:", with: "")
                UserDefaults.standard.setValue(testIntegration, forKey: "BraintreeDemoSettingsAuthorizationOverride")
            }
        }
        
        if ProcessInfo.processInfo.arguments.contains("-ClientTokenVersion2") {
            UserDefaults.standard.set("2", forKey: "BraintreeDemoSettingsClientTokenVersionDefaultsKey")
        } else if ProcessInfo.processInfo.arguments.contains("-ClientTokenVersion3") {
            UserDefaults.standard.set("3", forKey: "BraintreeDemoSettingsClientTokenVersionDefaultsKey")
        }
        // End checking for testing arguments
        
        guard let settingsBundle = Bundle.main.path(forResource: "Settings", ofType: "bundle"),
              let settings = NSDictionary(contentsOfFile: settingsBundle.appending("/Root.plist")) else {
            print("Could not find Settings.bundle")
            return
        }
                
        if let preferences = settings.object(forKey: "PreferenceSpecifiers") as? Array<[String: Any]> {
            var defaultsToRegister: [String: Any] = [:]
            preferences.forEach { prefSpecification in
                print(prefSpecification)
                if let key = prefSpecification["Key"] as? String, prefSpecification.keys.contains("DefaultValue") {
                    defaultsToRegister[key] = prefSpecification["DefaultValue"]
                }
            }
            
            UserDefaults.standard.register(defaults: defaultsToRegister)
        }
    }
}
