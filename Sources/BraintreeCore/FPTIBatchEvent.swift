import Foundation
import UIKit

// MARK: - Welcome
struct FPTIBatchEvent: Codable {
    let events: [Event]
}

// MARK: - Event
struct Event: Codable {
    let batchParams: BatchParams
    let eventParams: [EventParam]

    enum CodingKeys: String, CodingKey {
        case batchParams = "batch_params"
        case eventParams = "event_params"
    }
}

// MARK: - BatchParams
struct BatchParams: Codable {
    
    let appID: String = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String ?? "N/A"

    let appName: String = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "N/A"
    
    let authorizationFingerprint: String?
    
    let clientSDKVersion = BTCoreConstants.braintreeSDKVersion

    let clientOS: String = UIDevice.current.systemName + " " + UIDevice.current.systemVersion

    let component = "btmobilesdk"

    let deviceManufacturer = "Apple"

    let deviceModel: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }()

    let eventSource = "mobile-native"

    let environment: String
    
    let packageManager: String = {
        #if COCOAPODS
            "CocoaPods"
        #elseif SWIFT_PACKAGE
            "Swift Package Manager"
        #else
            "Carthage or Other"
        #endif
    }()

    let isSimulator: Bool = {
        #if targetEnvironment(simulator)
            true
        #else
            false
        #endif
    }()

    let merchantAppVersion: String = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String ?? "N/A"

    let merchantID: String
    
    let platform = "iOS"

    let sessionID: String
    
    let tenantName = "Braintree"
    
    let tokenizationKey: String?

    enum CodingKeys: String, CodingKey {
        case appID = "app_id"
        case appName = "app_name"
        case authorizationFingerprint = "auth_fingerprint"
        case clientSDKVersion = "c_sdk_ver"
        case clientOS = "client_os"
        case component = "comp"
        case deviceManufacturer = "device_manufacturer"
        case deviceModel = "mobile_device_model"
        case eventSource = "event_source"
        case environment = "merchant_sdk_env"
        case packageManager = "ios_package_manager"
        case isSimulator = "is_simulator"
        case merchantAppVersion = "mapv"
        case merchantID = "merchant_id"
        case platform = "platform"
        case sessionID = "session_id"
        case tenantName = "tenant_name"
        case tokenizationKey = "tokenization_key"
    }
}

// MARK: - EventParam
struct EventParam: Codable {
    
    let eventName: String
    let timestamp: String
    
    enum CodingKeys: String, CodingKey {
        case eventName = "event_name"
        case timestamp = "t"
    }
}
