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
        
        guard let settingsBundle = Bundle.main.path(forResource: "Settings", ofType: "bundle") else {
            print("Could not find Settings.bundle")
            return
        }
        
        let settings = NSDictionary(contentsOfFile: settingsBundle.appending("/Root.plist"))
        let preferences: NSArray = settings?.object(forKey: "PreferenceSpecifiers") as! NSArray
        
        var defaultsToRegister: [String: String] = [:]
        preferences.forEach { prefSpecification in
            let prefSpecification = prefSpecification as! NSDictionary
            let key = prefSpecification.object(forKey: "Key")
            if ((key != nil) && prefSpecification.allKeys.contains(where: { value in
                value as! String == "DefaultValue"
            })) {
                defaultsToRegister[key as! String] = "DefaultValue"
            }
        }
    }
}
