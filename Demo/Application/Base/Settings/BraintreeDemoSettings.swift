import Foundation

enum BraintreeDemoEnvironment: Int {
    case sandbox
    case production
    case custom
}

enum BraintreeDemoAuthType: Int {
    case clientToken
    case tokenizationKey
    case newPayPalCheckoutTokenizationKey
    case mockedPayPalTokenizationKey
    case uiTestHardcodedClientToken
}

enum BraintreeDemoThreeDSecureRequiredSetting: Int {
    case requiredIfAttempted
    case required
    case optional
}

class BraintreeDemoSettings: NSObject {
    
    static let EnvironmentDefaultsKey = "BraintreeDemoSettingsEnvironmentDefaultsKey"
    static let AuthorizationTypeDefaultsKey = "BraintreeDemoSettingsAuthorizationTypeKey"
    static let CustomAuthorizationDefaultsKey = "BraintreeDemoSettingsCustomAuthorizationKey"
    static let ThreeDSecureRequiredDefaultsKey = "BraintreeDemoSettingsThreeDSecureRequiredDefaultsKey"

    static var currentEnvironment: BraintreeDemoEnvironment {
        BraintreeDemoEnvironment(
            rawValue: UserDefaults.standard.integer(forKey: EnvironmentDefaultsKey)
        ) ?? BraintreeDemoEnvironment.sandbox
    }

    static var currentEnvironmentName: String {
        switch currentEnvironment {
        case .sandbox, .custom:
            return "Sandbox"
        case .production:
            return "Production"
        }
    }

    static var currentEnvironmentURLString: String {
        switch currentEnvironment {
        case .sandbox, .custom:
            return "https://braintree-sample-merchant.herokuapp.com"
        case .production:
            return "https://executive-sample-merchant.herokuapp.com"
        }
    }
    
    static var authorizationOverride: String? {
        return UserDefaults.standard.string(forKey: "BraintreeDemoSettingsAuthorizationOverride")
    }

    static var authorizationType: BraintreeDemoAuthType {
        BraintreeDemoAuthType(rawValue: UserDefaults.standard.integer(forKey: AuthorizationTypeDefaultsKey)) ?? .tokenizationKey
    }
    
    static var threeDSecureRequiredStatus: BraintreeDemoThreeDSecureRequiredSetting {
        BraintreeDemoThreeDSecureRequiredSetting(
            rawValue: UserDefaults.standard.integer(forKey: ThreeDSecureRequiredDefaultsKey)
        ) ?? .requiredIfAttempted
    }

    static var customerPresent: Bool {
        return UserDefaults.standard.bool(forKey: "BraintreeDemoCustomerPresent")
    }
    
    static var customerIdentifier: String? {
        return UserDefaults.standard.string(forKey: "BraintreeDemoCustomerIdentifier")
    }

    static var clientTokenVersion: String? {
        return UserDefaults.standard.string(forKey: "BraintreeDemoSettingsClientTokenVersionDefaultsKey")
    }
}
