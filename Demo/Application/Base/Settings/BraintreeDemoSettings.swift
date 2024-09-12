import Foundation

@objc
enum BraintreeDemoEnvironment: Int {
    case sandbox
    case production
    case custom
}

@objc
enum BraintreeDemoAuthType: Int {
    case clientToken
    case tokenizationKey
    case newPayPalCheckoutTokenizationKey
    case mockedPayPalTokenizationKey
    case uiTestHardcodedClientToken
}

@objc
enum BraintreeDemoThreeDSecureRequiredSetting: Int {
    case requiredIfAttempted
    case required
    case optional
}

@objc
class BraintreeDemoSettings: NSObject {
    
    @objc static let EnvironmentDefaultsKey = "BraintreeDemoSettingsEnvironmentDefaultsKey"
    @objc static let AuthorizationTypeDefaultsKey = "BraintreeDemoSettingsAuthorizationTypeKey"
    @objc static let CustomAuthorizationDefaultsKey = "BraintreeDemoSettingsCustomAuthorizationKey"
    @objc static let ThreeDSecureRequiredDefaultsKey = "BraintreeDemoSettingsThreeDSecureRequiredDefaultsKey"

    @objc
    static var currentEnvironment: BraintreeDemoEnvironment {
        return BraintreeDemoEnvironment(rawValue: UserDefaults.standard.integer(forKey: EnvironmentDefaultsKey)) ?? BraintreeDemoEnvironment.sandbox
    }

    @objc
    static var currentEnvironmentName: String {
        switch currentEnvironment {
        case .sandbox, .custom:
            return "Sandbox"
        case .production:
            return "Production"
        }
    }
    
    @objc
    static var currentEnvironmentURLString: String {
        switch currentEnvironment {
        case .sandbox, .custom:
            return "https://braintree-sample-merchant.herokuapp.com"
        case .production:
            return "https://executive-sample-merchant.herokuapp.com"
        }
    }
    
    @objc
    static var authorizationOverride: String? {
        return UserDefaults.standard.string(forKey: "BraintreeDemoSettingsAuthorizationOverride")
    }

    @objc
    static var authorizationType: BraintreeDemoAuthType {
        return BraintreeDemoAuthType(rawValue: UserDefaults.standard.integer(forKey: AuthorizationTypeDefaultsKey))!
    }
    
    @objc
    static var threeDSecureRequiredStatus: BraintreeDemoThreeDSecureRequiredSetting {
        return BraintreeDemoThreeDSecureRequiredSetting(rawValue: UserDefaults.standard.integer(forKey: ThreeDSecureRequiredDefaultsKey)) ?? .requiredIfAttempted
    }

    @objc
    static var customerPresent: Bool {
        return UserDefaults.standard.bool(forKey: "BraintreeDemoCustomerPresent")
    }
    
    @objc
    static var customerIdentifier: String? {
        return UserDefaults.standard.string(forKey: "BraintreeDemoCustomerIdentifier")
    }

    @objc
    static var clientTokenVersion: String? {
        return UserDefaults.standard.string(forKey: "BraintreeDemoSettingsClientTokenVersionDefaultsKey")
    }
}
